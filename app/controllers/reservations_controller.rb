class ReservationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :reservation_params, only: :create
  def new
    @reservation = Reservation.new
  end

  def destroy_wait_list
    ActiveRecord::Base.transaction do
      waiting_passenger = WaitList.find(params[:waitlist_id].to_i)
      passenger = Passenger.find(params[:passenger_id].to_i)

      cancel_waiting_passenger(waiting_passenger, passenger)

      payment = Payment.find_by(
        reservation_id: passenger.reservation.id,
        train_id: passenger.reservation.train_detail.id,
        berth: passenger.reservation.berth_class
      )

      raise ActiveRecord::Rollback, 'Payment not found' unless payment

      redirect_to payments_refund_url(
        payment_intent_id: payment.payment_intent_id,
        train_detail_id: passenger.reservation.train_detail.id,
        berth: passenger.reservation.berth_class,
        passenger_id: params[:passenger_id].to_i
      ), notice: 'Reservation Cancelled !'
    end
  rescue ActiveRecord::Rollback
    redirect_to waitlist_url, alert: 'Failed to cancel reservation, please try again.'
  end

  def destroy_confirm
    ActiveRecord::Base.transaction do
      passenger = Passenger.find(params[:id].to_i)

      if WaitList.exists?(available_id: params[:available_id], train_detail_id: params[:train_detail_id],
                          berth_class: params[:berth_class], dates: params[:date])
        waiting_passenger = WaitList.find_by(
          available_id: params[:available_id],
          train_detail_id: params[:train_detail_id],
          berth_class: params[:berth_class]
        )
        manage_waitlist(waiting_passenger, passenger)
      else
        increase_availability(params[:berth_class], passenger)
        seat_delocate(params[:berth_class], params[:available_id], params[:train_detail_id], params[:date], passenger)
        passenger.ticket_status = 'Cancelled'
        passenger.seat_number = nil
        passenger.save
      end

      payment = Payment.find_by(reservation_id: passenger.reservation.id, train_id: passenger.reservation.train_detail.id,
                                berth: passenger.reservation.berth_class)

      raise ActiveRecord::Rollback, 'Payment not found' unless payment

      redirect_to payments_refund_url(payment_intent_id: payment.payment_intent_id,
                                      train_detail_id: passenger.reservation.train_detail.id,
                                      berth: passenger.reservation.berth_class, passenger_id: params[:id].to_i), notice: 'Reservation Cancelled!'
    end
  rescue ActiveRecord::Rollback
    redirect_to waitlist_url, alert: 'Failed to cancel reservation, please try again.'
  end

  def create
    ActiveRecord::Base.transaction do
      @reservation = Reservation.new(reservation_params.except(:existing_passenger_ids))
      @train_id = params[:train_detail_id].to_i
      existing_passenger_ids = reservation_params[:existing_passenger_ids]&.reject(&:blank?)
      passengers = reservation_params[:passengers_attributes]&.to_h
      new_passengers = passengers.present? && passengers.any? { |_, v| v[:passenger_name].present? }

      # Validating if at least one passenger exists
      unless existing_passenger_ids.present? || new_passengers
        redirect_to new_search_path, notice: 'Please select existing passengers or add new passengers.'
        return
      end

      if @reservation.save
        if params[:reservation][:existing_passenger_ids].present?
          existing_passenger_ids = params[:reservation][:existing_passenger_ids].reject(&:blank?)
          existing_passenger_ids.each do |passenger_id|
            @reservation.passengers << Passenger.find(passenger_id)
          end
        end

        count = @reservation.passengers.count
        passengers_detail = @reservation.passengers
        @reservation.check_and_create_seat(
          @reservation.date,
          @reservation.train_detail_id,
          @reservation.available_id,
          count,
          passengers_detail
        )

        add_waiting(passengers_detail)
        @reservation.save
        redirect_to payments_create_url(train_detail_id: @reservation.train_detail_id,
                                        berth_class: @reservation.berth_class, reserved_id: @reservation.id)
      else
        redirect_to new_search_path, notice: @reservation.errors.full_messages
      end
    end
  end

  private

  def send_cancellation_email(reservation, passenger)
    ReservationMailer.cancellation_email(reservation, passenger).deliver_now
    flash[:notice] = 'Cancellation email sent to the Passenger.'
  end

  def reservation_params
    params.require(:reservation).permit(
      :email,
      :phone_number,
      :train_detail_id,
      :available_id,
      :berth_class,
      :date,
      passengers_attributes: %i[
        id
        passenger_name
        date_of_birth
        gender
      ],
      existing_passenger_ids: []
    )
  end

  def add_waiting(passengers_detail)
    passenger_nil_seat = passengers_detail.where(seat_number: nil) # Finding the passenger who have nil in seat
    passenger_nil_seat.each do |passenger|
      WaitList.create(
        dates: @reservation.date,
        train_detail_id: @reservation.train_detail_id,
        available_id: @reservation.available_id,
        berth_class: @reservation.berth_class,
        reservation_id: @reservation.id,
        passenger_name: passenger.passenger_name,
        passenger_id: passenger.id
      )
      passenger.update(ticket_status: 'Pending')
    end
  end

  # Increase availability after ticket cancellation
  def increase_availability(berth, passenger)
    reserved = passenger.reservation
    case berth
    when '2AC'
      reserved.available.increment!(:_2AC_available)
    when '1AC'
      reserved.available.increment!(:_1AC_available)
    else
      reserved.available.increment!(:general_available)
    end
  end

  def manage_waitlist(_waiting_passenger, passenger)
    # Find the reservation for the passenger whose seat number is being assigned
    wait_first_passenger = WaitList.find_by(available_id: params[:available_id],
                                            train_detail_id: params[:train_detail_id], berth_class: params[:berth_class], dates: params[:date])
    wait_passenger = Passenger.find_by(id: wait_first_passenger.passenger_id)
    wait_passenger.seat_number = passenger.seat_number
    wait_passenger.ticket_status = 'Done'
    wait_first_passenger.destroy
    wait_passenger.save

    passenger.ticket_status = 'Cancelled'
    passenger.seat_number = nil
    passenger.save
  end

  def seat_delocate(berth, availability_id, train_id, date, passenger)
    seat = Seat.find_by(train_detail_id: train_id, available_id: availability_id, dates: date)
    value = passenger.seat_number

    if berth == '2AC'
      seat.occupied_2AC_seats.shift(value)
      seat.available_2AC_seats.unshift(value)
      seat.available_2AC_seats.sort
    elsif berth == '1AC'
      seat.occupied_1AC_seats.shift(value)
      seat.available_1AC_seats.unshift(value)
      seat.available_1AC_seats.sort
    else
      seat.occupied_general_seats.shift(value)
      seat.available_general_seats.unshift(value)
      seat.available_general_seats.sort
    end
  end

  def cancel_waiting_passenger(waiting_passenger, passenger)
    passenger.ticket_status = 'Cancelled'
    passenger.save
    waiting_passenger.destroy
  end
end
