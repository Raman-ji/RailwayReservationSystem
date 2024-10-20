class PaymentsController < ApplicationController
  def create
    train = TrainDetail.find(params[:train_detail_id].to_i)
    berth = params[:berth_class]

    amount = case berth
             when '2AC'
               train.class_2a_price
             when '1AC'
               train.class_1a_price
             else
               train.class_general_price
             end

    product = Stripe::Product.create({
                                       name: "#{train.train_name}, #{berth}"
                                     })

    price = Stripe::Price.create({
                                   product: product.id,
                                   unit_amount: amount,
                                   currency: 'usd'
                                 })

    reservation = Reservation.find(params[:reserved_id].to_i)
    count = reservation.passengers.count
    session = Stripe::Checkout::Session.create({
                                                 payment_method_types: ['card'],
                                                 line_items: [{
                                                   price: price.id,
                                                   quantity: count
                                                 }],
                                                 mode: 'payment',
                                                 success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}&reserved_id=#{reservation.id}&berth=#{reservation.berth_class}&train_id=#{reservation.train_detail_id}",
                                                 cancel_url: checkout_cancel_url
                                               })
    redirect_to session.url, allow_other_host: true
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])

    payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)

    Payment.create!(
      reservation_id: params[:reserved_id].to_i,
      payment_intent_id: payment_intent.id,
      amount: payment_intent.amount,
      status: payment_intent.status,
      date: Date.today,
      berth: params[:berth],
      train_id: params[:train_id],
      currency: 'usd'
    )
    reservation = Reservation.find(params[:reserved_id].to_i)
    reservation.payment_status = 'Done'
    reservation.save
    send_confirmation_email(params[:reserved_id].to_i)
    render plain: 'Payment was successful!'
  end

  def send_confirmation_email(reserved_id)
    @reservation = Reservation.find(reserved_id)
    ReservationMailer.confirmation_email(@reservation).deliver_now
    flash[:notice] = 'Confirmation email sent to the Passenger.'
  end

  def cancel
    render plain: 'Payment was cancelled.'
  end

  def refund
    payment_intent_id = params[:payment_intent_id]
    train = TrainDetail.find(params[:train_detail_id].to_i)
    berth = params[:berth]
    passenger = Passenger.find(params[:passenger_id].to_i)
    amount_to_be_refunded = case berth
                            when '2AC'
                              train.class_2a_price
                            when '1AC'
                              train.class_1a_price
                            else
                              train.class_general_price
                            end

    refund = Stripe::Refund.create({
                                     payment_intent: payment_intent_id,
                                     amount: amount_to_be_refunded
                                   })

    payment = Payment.find_by(payment_intent_id:)
    payment.update(status: 'Refunded')
    payment.update(passenger_name: passenger.passenger_name)
    reservation = passenger.reservation
    send_cancellation_email(reservation, passenger)
    render plain: 'Payment has been refunded!'
  end

  def send_cancellation_email(reservation, passenger)
    ReservationMailer.cancellation_email(reservation, passenger).deliver_now
    flash[:notice] = 'Cancellation email sent to the Passenger.'
  end
end
