class ReservationsController < ApplicationController
  def create
    reservation = Reservation.create!(passenger_params)
    
  end
end

private

def passenger_params
  params.permit(:passenger_name, :age, :gender, :date_of_birth, :birth_class)
end