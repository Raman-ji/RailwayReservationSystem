class ReservationsController < ApplicationController
  before_action :reservation_params, only: :create
  # befor_action  :cancellation_params, only: :destroy
  def new
    @reservation = Reservation.new
  end

  def destroy
    waiting_passenger = WaitList.find_by(available_id: params[:available_id], train_detail_id: params[:train_detail_id], berth_class: params[:berth_class])
    passenger = Reservation.find_by(id: params[:id].to_i)
    debugger
    if WaitList.exists?(reservation_id: params[:id])
      debugger
      cancel_wait_list(params[:id])
    elsif passenger.nil?
      redirect_to new_search_path, alert: 'Reservation not found.'
      return
    elsif waiting_passenger.nil?
      increase_availability(params[:berth_class], passenger, params[:available_id], params[:train_detail_id], params[:date])
      seat_adjustment(params[:berth_class], params[:available_id], params[:train_detail_id], params[:date], passenger)
    else
      manage_waitlist(waiting_passenger, passenger.id) 
    end
    # refund code remains
    # mailer code remains
    passenger.ticket_status = 'Cancelled'
    passenger.payment_status = 'Refunded' # This line will be replaced when we are using payment stripe 
    passenger.save
    redirect_to new_search_path, notice: 'Reservation cancelled'
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.age = @reservation.calculate_age

    if session[:submission_tokens]&.include?(params[:submission_token])
      flash.now[:alert] = "You have already submitted this form."
      # redirect_to new_reservation_path and return
    elsif @reservation.save
      session[:submission_tokens] ||= []
      session[:submission_tokens] << params[:submission_token]
 
      @reservation.check_and_create_seat(@reservation.date, @reservation.train_detail_id, @reservation.available_id)
      add_waiting
      decrease_availability(@reservation.berth_class) if @reservation.seat_numbers.present?
    else
      puts @reservation.errors.full_messages
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:passenger_name, :age, :gender, :date_of_birth, :email, :phone_number, :train_detail_id, :available_id, :berth_class, :date)
  end

  def add_waiting
    if @reservation.seat_numbers.nil?
      WaitList.create(
        dates: @reservation.date,
        train_detail_id: @reservation.train_detail_id,
        available_id: @reservation.available_id,
        berth_class: @reservation.berth_class,
        reservation_id: @reservation.id
      )
      @reservation.ticket_status = 'Pending'
      @reservation.save
    end
  end

   # after getting a seat decrease there count
   def decrease_availability(berth)
     case berth
     when '2AC'
       @reservation.available.decrement!(:_2AC_available) if @reservation.available._2AC_available.positive?
     when '1AC'
       @reservation.available.decrement!(:_1AC_available) if @reservation.available._1AC_available.positive?
     else
       @reservation.available.decrement!(:general_available) if @reservation.available.general_available.positive?
     end
  end

  # Increase availability after ticket cancellation
  def increase_availability(berth, passenger, available_id, train_id, date)
    case berth
    when '2AC'
      passenger.available.increment!(:_2AC_available)
    when '1AC'
      passenger.available.increment!(:_1AC_available)
    else
      passenger.available.increment!(:general_available)
    end 
  end

  def manage_waitlist(waiting_passenger, id)
    passenger = Reservation.find(id)
    waiting_passenger.reservation.seat_numbers = passenger.seat_numbers
    # update payment status by a payment gateway 
    waiting_passenger.reservation.save
  end

  def seat_adjustment(berth, available_id, train_id, date, passenger)
    seat = Seat.find_by(train_detail_id: train_id, available_id: available_id, dates: date)
    value = passenger.seat_numbers
    if berth == '2AC'
      data = seat.occupied_2AC_seats.index(value)
      seat.available_2AC_seats.insert( data, value)
      seat.available_2AC_seats.sort
    elsif berth == '1AC'
      data = seat.occupied_1AC_seats.index(value)
      seat.available_1AC_seats.insert(data, value)
      seat.available_1AC_seats.sort
    else
      data = seat.occupied_general_seats.index(value)
      seat.available_general_seats.insert(data, value)
      seat.available_general_seats.sort
    end
  end

  def cancel_wait_list(id)
    WaitList.find_by(reservation_id: id).destroy
  end
end
