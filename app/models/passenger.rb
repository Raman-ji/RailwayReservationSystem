class Passenger < ApplicationRecord
  belongs_to :reservation
  has_one :wait_list
  validate :date_of_birth_validity
  with_options presence: true do
    validates :passenger_name, :gender, :date_of_birth
  end

  before_save do
    self.passenger_name = passenger_name.titleize if passenger_name.present?
  end

  before_save :generate_pnr

  def date_of_birth_validity
    return if date_of_birth.blank?

    today = Date.today
    hundred_ten_years_ago = today - 110.years
    dob = Date.parse(self.date_of_birth)
    if dob > today
      errors.add(:date_of_birth, 'cannot be in the future.')
    elsif dob < hundred_ten_years_ago
      errors.add(:date_of_birth, 'cannot be more than 110 years ago.')
    end
  end

  def generate_pnr
    self.pnr = loop do
      number = Random.rand(1_000_000_000..9_999_999_999)
      break number unless Passenger.exists?(pnr: number)
    end
  end
end
