class Reservation < ApplicationRecord
  serialize :payment_status, coder: JSON
  has_one :wait_list, dependent: :destroy
  has_many :passengers, dependent: :destroy
  belongs_to :train_detail
  belongs_to :available
  accepts_nested_attributes_for :passengers, allow_destroy: true

  with_options presence: true do
    validates :berth_class, :email, :phone_number, :train_detail_id, :available_id
  end

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valide phone number ' }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      available_id
      berth_class
      created_at
      date
      email
      gender
      id
      id_value
      payment_status
      phone_number
      train_detail_id
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[available train_detail]
  end

  def check_availability(passenger_count, passengers)
    passengers.each do |passenger|
      seat = case berth_class
        when '2AC'
          available._2AC_available.zero? ? nil : seat_allotment(berth_class)
        when '1AC'
          available._1AC_available.zero? ? nil : seat_allotment(berth_class)
        else
          available.general_available.zero? ? nil : seat_allotment(berth_class)
        end
      passenger.seat_number = seat
      passenger.save
    end
  end

  def seat_allotment(berth_class)
    if berth_class == '2AC'
      seat = @seat.available_2AC_seats.shift
      @seat.occupied_2AC_seats.unshift(seat)
    elsif berth_class == '1AC'
      seat = @seat.available_1AC_seats.shift
      @seat.occupied_1AC_seats.unshift(seat)
    else
      seat = @seat.available_general_seats.shift
      @seat.occupied_general_seats.unshift(seat)
    end
    @seat.save
    decrease_availability(berth_class)
    seat
  end

  def check_and_create_seat(date, train_id, available_id, passenger_count, passenger)
    @seat = if Seat.exists?(dates: date, train_detail_id: train_id)
              finding(date, train_id)
            else
              creating(date, train_id, available_id)
            end
    check_availability(passenger_count, passenger)
  end

  def finding(date, train_id)
    Seat.find_by(dates: date, train_detail_id: train_id)
  end

  def creating(date, train_id, availability_id)
    seat = Seat.create(dates: date, train_detail_id: train_id, available_id: availability_id)
    seat.update(available_2AC_seats: (1..seat.train_detail.class_2a_count).to_a, occupied_2AC_seats: Array(nil))
    seat.update(available_1AC_seats: (1..seat.train_detail.class_1a_count).to_a, occupied_1AC_seats: Array(nil))
    seat.update(available_general_seats: (1..seat.train_detail.class_general_count).to_a,
                occupied_general_seats: Array(nil))
    seat
  end

  # after getting a seat decrease there count
  def decrease_availability(berth)
    case berth
    when '2AC'
      self.available.decrement!(:_2AC_available) if self.available._2AC_available.positive?
    when '1AC'
      self.available.decrement!(:_1AC_available) if self.available._1AC_available.positive?
    else
      self.available.decrement!(:general_available) if self.available.general_available.positive?
    end
  end
end
