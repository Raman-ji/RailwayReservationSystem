class ReservationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :reservation_params, only: :create
  # befor_action  :cancellation_params, only: :destroy
  def new
    @reservation = Reservation.new
    1.times { @reservation.passengers.build }
  end

  def destroy
    waiting_passenger = WaitList.find_by(
      available_id: params[:available_id],
      train_detail_id: params[:train_detail_id],
      berth_class: params[:berth_class]
    )

    passenger = Reservation.find_by(id: params[:id].to_i)

    if WaitList.exists?(reservation_id: params[:id])
      cancel_wait_list(params[:id], params[:index].to_i, waiting_passenger)
    elsif passenger.nil?
      redirect_to new_search_path, alert: 'Reservation not found.' and return
    elsif waiting_passenger.nil?
      increase_availability(params[:berth_class], passenger)
      seat_delocate(params[:berth_class], params[:available_id], params[:train_detail_id], params[:date], passenger, params[:index].to_i)
    else
      manage_waitlist(waiting_passenger, passenger.id, params[:index].to_i)
    end
    # Process refund
    # Process email notification
    ticket_status = passenger.ticket_status || []
    payment_status = passenger.payment_status || []

    index = params[:correct_index].to_i

    # Only proceed if the index exists within the array bounds
    if index < ticket_status.length && index < payment_status.length
      ticket_status[index] = 'Cancelled'
      payment_status[index] = 'Refunded'
      passenger.seat_numbers.delete_at(index)
      passenger.update(ticket_status: ticket_status, payment_status: payment_status)
      redirect_to new_search_path, notice: 'Reservation cancelled'
    else
      redirect_to new_search_path, alert: 'Invalid index for updating status.'
    end
  end

  def create
    byebug
    @reservation = Reservation.new(reservation_params)
    # After payment manage payment status and ticket status
    if @reservation.save
      @reservation.check_and_create_seat(
        @reservation.date,
        @reservation.train_detail_id,
        @reservation.available_id,
        @reservation.passenger_name.size
      )
      add_passenger
      add_waiting
      decrease_availability(@reservation.berth_class) if @reservation.seat_numbers.present?
      redirect_to new_search_path, notice: 'Reservation created'
    else
      byebug
      puts "mistake"
      redirect_to new_search_path, notice: 'Reservation error'
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(
      :email,
      :phone_number,
      :train_detail_id,
      :available_id,
      :berth_class,
      :date,
      passengers_attributes: [
        :passenger_name,
        :date_of_birth,
        :gender
      ]
    )
  end

  def add_waiting
    return unless @reservation.seat_numbers.size != @reservation.passenger_name.size

    # Calculate how many passengers need to be added to the waitlist
    count = @reservation.seat_numbers.size
    remaining_passengers = @reservation.passenger_name[count..]

    remaining_pnr = @reservation.pnr[count..]
    # Create a waitlist entry for the remaining passengers
    waiting_passenger = WaitList.create(
      dates: @reservation.date,
      train_detail_id: @reservation.train_detail_id,
      available_id: @reservation.available_id,
      berth_class: @reservation.berth_class,
      reservation_id: @reservation.id,
      passenger_names: remaining_passengers,
    )
    ticket_status = @reservation.ticket_status || []
    remaining_passengers.each_with_index do |_, index|
      ticket_status[count + index] = 'Pending'
    end
    @reservation.update(ticket_status: ticket_status)
    waiting_passenger.update(wait_pnr: remaining_pnr)
  end

  # after getting a seat decrease there count
  def decrease_availability(berth)
    case berth
    when '2AC'
      if @reservation.available._2AC_available.positive?
        @reservation.available.decrement!(:_2AC_available,
                                          @reservation.seat_numbers.size)
      end
    when '1AC'
      if @reservation.available._1AC_available.positive?
        @reservation.available.decrement!(:_1AC_available,
                                          @reservation.seat_numbers.size)
      end
    else
      if @reservation.available.general_available.positive?
        @reservation.available.decrement!(:general_available,
                                          @reservation.seat_numbers.size)
      end
    end
  end

  # Increase availability after ticket cancellation
  def increase_availability(berth, passenger)
    case berth
    when '2AC'
      passenger.available.increment!(:_2AC_available)
    when '1AC'
      passenger.available.increment!(:_1AC_available)
    else
      passenger.available.increment!(:general_available)
    end
  end

  def manage_waitlist(waiting_passenger, id, index)
    # Find the reservation for the passenger whose seat number is being assigned
    reserve_passenger = Reservation.find(id)
    if index < reserve_passenger.seat_numbers.length && index < waiting_passenger.reservation.seat_numbers.length
      waiting_passenger.reservation.seat_numbers[index] = passenger.seat_numbers[index]

      if waiting_passenger.reservation.save
        waiting_passenger.reservation.ticket_status[index] = 'Done'
      else
        render plain: 'Error saving reservation for waiting passenger.'
      end
    else
      render plain: 'Index out of bounds.'
    end

    passenger.ticket_status[index] = 'Cancelled'
  end

  def seat_delocate(berth, availability_id, train_id, date, _passenger, index)
    seat = Seat.find_by(train_detail_id: train_id, available_id: availability_id, dates: date)
    value = _passenger.seat_numbers[index]

    if berth == '2AC'
      index_data = seat.occupied_2AC_seats.index(value)
      seat.available_2AC_seats.insert(index_data, value)
      seat.occupied_2AC_seats.shift(value)
      seat.available_2AC_seats.sort
    elsif berth == '1AC'
      index_data = seat.occupied_1AC_seats.index(value)
      seat.available_1AC_seats.insert(index_data, value)
      seat.occupied_1AC_seats.shift(value)
      seat.available_1AC_seats.sort
    else
      index_data = seat.occupied_general_seats.index(value)
      seat.available_general_seats.insert(index_data, value)
      seat.occupied_general_seats.shift(value)
      seat.available_general_seats.sort
    end
  end

  def cancel_wait_list(_id, index, waiting_passenger)
    waiting_passenger.passenger_names.delete_at(index)
    waiting_passenger.wait_pnr.delete_at(index)
    waiting_passenger.save
  end
end
