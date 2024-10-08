class Reservation < ApplicationRecord
  serialize :date_of_birth, coder: JSON
  serialize :passenger_name, coder: JSON
  serialize :gender, coder: JSON
  serialize :seat_numbers, coder: JSON
  serialize :pnr, coder: JSON
  serialize :train_status, coder: JSON
  serialize :payment_status, coder: JSON
  serialize :ticket_status, coder:JSON

  has_one :wait_list, dependent: :destroy
  belongs_to :train_detail
  belongs_to :available

  with_options presence: true do
    validates :berth_class, :email, :phone_number, :train_detail_id, :available_id
  end

  validate :validate_passenger_details
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valide phone number ' }
  validate :date_of_birth_validity
  before_create :generate_pnr

  before_save do
    if passenger_name.present?
      self.passenger_name = passenger_name.map(&:titleize)
    end
  end

  def validate_passenger_details
    if passenger_name.blank? || passenger_name.any?(&:blank?)
      errors.add(:passenger_name, 'cannot be blank')
    end

    if gender.blank? || gender.any?(&:blank?)
      errors.add(:gender, 'cannot be blank')
    end

    if date_of_birth.blank? || date_of_birth.any?(&:blank?)
      errors.add(:date_of_birth, 'cannot be blank')
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
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

    date_of_birth.each do |dob|
      dob = Date.parse(dob) rescue nil
      next unless dob # Skip if the date is invalid
      if dob > today
        errors.add(:date_of_birth, 'cannot be in the future.')
      elsif dob < hundred_ten_years_ago
        errors.add(:date_of_birth, 'cannot be more than 110 years ago.')
      end
    end
  end

  def check_availability(passenger_count)
    seat_number = case berth_class
                  when '2AC'
                    available._2AC_available.size < passenger_count ? nil : seat_allotment(berth_class, passenger_count)
                  when '1AC'
                    available._1AC_available.size < passenger_count ? nil : seat_allotment(berth_class, passenger_count)
                  else
                    available.general_available.size < passenger_count ? nil : seat_allotment(berth_class, passenger_count)
                  end
    self.seat_numbers = seat_number
    save
  end

  def seat_allotment(berth_class, count)
    seats = []
    if berth_class == '2AC'
      count -= (count - @seat.available_2AC_seats.size) if count > @seat.available_2AC_seats.size
      seats = @seat.available_2AC_seats.shift(count)
      @seat.occupied_2AC_seats.unshift(*seats)

    elsif berth_class == '1AC'
      count -= (count - @seat.available_2AC_seats.size) if count > @seat.available_1AC_seats.size
      seats = @seat.available_1AC_seats.shift(count)
      @seat.occupied_1AC_seats.unshift(*seats)

    else
      count -= (count - @seat.available_general_seats.size) if count > @seat.available_general_seats.size
      seats = @seat.available_general_seats.shift(count)
      @seat.occupied_general_seats.unshift(*seats)
    end
    @seat.save
    seats
  end

  def check_and_create_seat(date, train_id, available_id, passenger_count)
    @seat = if Seat.exists?(dates: date, train_detail_id: train_id)
              finding(date, train_id)
            else
              creating(date, train_id, available_id)
            end
    check_availability(passenger_count)
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

  private

  def generate_pnr
    numbers = [] # Initialize an empty array to hold the PNR numbers
    self.passenger_name.each do
      # Generate a unique PNR number for each passenger
      loop do
        pnr_number = Random.rand(1_000_000_000..9_999_999_999)
        break pnr_number unless numbers.include?(pnr_number) || Reservation.exists?(pnr: pnr_number)
      end.tap { |unique_number| numbers << unique_number } # Append the unique number to the array
    end
    self.pnr = numbers # Assign the array of unique PNRs to self.pnr
  end
end
