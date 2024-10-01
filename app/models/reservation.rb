class Reservation < ApplicationRecord
  #has_one :seat, dependent: :destroy
  has_one :wait_list, dependent: :destroy
  belongs_to :train_detail
  belongs_to :available

  with_options presence: true do
    validates :passenger_name, :age, :gender, :date_of_birth, :berth_class, :email, :phone_number, :train_detail_id,
              :available_id
  end

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valide phone number ' }
  validate :date_of_birth_validity
  before_save :generate_pnr

  before_save do
    self.passenger_name = passenger_name.titleize if passenger_name.present?
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      age
      available_id
      berth_class
      created_at
      date
      date_of_birth
      email
      gender
      id
      id_value
      passenger_name
      payment_status
      phone_number
      pnr
      seat_numbers
      ticket_status
      train_detail_id
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[available train_detail] # Add your actual associations here
  end

  def date_of_birth_validity
    return unless date_of_birth.present?

    today = Date.today
    hundred_ten_years_ago = today - 110.years

    if date_of_birth > today
      errors.add(:date_of_birth, 'cannot be in the future.')
    elsif date_of_birth < hundred_ten_years_ago
      errors.add(:date_of_birth, 'cannot be more than 110 years ago.')
    end
  end

  def calculate_age
    return unless date_of_birth.present?

    ((Date.today - date_of_birth) / 365.25).to_i
  end

  def check_availability
    seat_number = case berth_class
                  when '2AC'
                    available._2AC_available.zero? ? nil : seat_allotment(berth_class)
                  when '1AC'
                    available._1AC_available.zero? ? nil : seat_allotment(berth_class)
                  else
                    available.general_available.zero? ? nil : seat_allotment(berth_class)
                  end
    self.seat_numbers = seat_number
    save
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
    seat
  end

  def check_and_create_seat(date, train_id, available_id)
    @seat = if Seat.exists?(dates: date, train_detail_id: train_id)
              finding(date, train_id)
            else
              creating(date, train_id, available_id)
            end
    check_availability
  end

  def finding(date, train_id)
    Seat.find_by(dates: date, train_detail_id: train_id)
  end

  def creating(date, train_id, availability_id)
    seat = Seat.create(dates: date, train_detail_id: train_id, available_id: availability_id )
    seat.update(available_2AC_seats: (1..seat.train_detail.class_2a_count).to_a, occupied_2AC_seats: Array(nil))
    seat.update(available_1AC_seats: (1..seat.train_detail.class_1a_count).to_a, occupied_1AC_seats: Array(nil))
    seat.update(available_general_seats: (1..seat.train_detail.class_general_count).to_a,
                occupied_general_seats: Array(nil))
    seat
  end

  private

  def generate_pnr
    self.pnr = loop do
      number = Random.rand(1_000_000_000..9_999_999_999)
      break number unless Reservation.exists?(pnr: number)
    end
  end
end
