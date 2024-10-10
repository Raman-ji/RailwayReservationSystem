class ReservationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :reservation_params, only: :create
  # befor_action  :cancellation_params, only: :destroy
  def new
    @reservation = Reservation.new
    @reservation.passengers.build
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
      seat_delocate(params[:berth_class], params[:available_id], params[:train_detail_id], params[:date], passenger,
                    params[:index].to_i)
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
      passenger.update(ticket_status:, payment_status:)
      redirect_to new_search_path, notice: 'Reservation cancelled'
    else
      redirect_to new_search_path, alert: 'Invalid index for updating status.'
    end
  end

  def create
    @reservation = Reservation.new(reservation_params)
    # After payment manage payment status and ticket status
    if @reservation.save
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
      redirect_to new_search_path, notice: 'Reservation created'
    else
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
      passengers_attributes: %i[
        id
        passenger_name
        date_of_birth
        gender
      ]
    )
  end

  def add_waiting(passengers_detail)
    passenger_nil_seat = passengers_detail.where(seat_number: nil) # Finding the passenger who have nil in seat
    passenger_nil_seat.each do
      WaitList.create(
        dates: @reservation.date,
        train_detail_id: @reservation.train_detail_id,
        available_id: @reservation.available_id,
        berth_class: @reservation.berth_class,
        reservation_id: @reservation.id,
        passenger_names: passenger_nil_seat.passenger_name,
        wait_pnr: passenger_nil_seat.pnr
      )
      passenger_nil_seat.ticket_status = 'Pending'
      passenger_nil_seat.save
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
