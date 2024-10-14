class ReservationMailer < ApplicationMailer
  default from: 'rg8154054@gmail.com'

  def confirmation_email(reservation)
    @reservation = reservation
    mail(to: @reservation.email, subject: 'Confirmation email for ticket booking')
  end

  def cancellation_email(reservation, passenger)
    @reservation = reservation
    @passenger = passenger
    mail(to: @reservation.email, subject: 'Ticket Cancellation email ')
  end
end
