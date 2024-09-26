class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new 
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.age = @reservation.calculate_age

    if @reservation.save
      @reservation.check_and_create_seat(@reservation.date, @reservation.train_detail_id, @reservation.available_id)
      decrease_availability(@reservation.berth_class) if @reservation.seat_numbers.present?
    else
      puts @reservation.errors.full_messages
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

  private

  def reservation_params
    params.require(:reservation).permit(:passenger_name, :age, :gender, :date_of_birth, :email, :phone_number, :train_detail_id, :available_id, :berth_class, :date)
  end
end