class Seat < ApplicationRecord
  belongs_to :train_detail
  belongs_to :available

  serialize :available_2AC_seats, coder: JSON
  serialize :occupied_2AC_seats, coder: JSON
  serialize :available_1AC_seats, coder: JSON
  serialize :occupied_1AC_seats, coder: JSON
  serialize :available_general_seats, coder: JSON
  serialize :occupied_general_seats, coder: JSON

  validates :dates, presence: true
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      available_1AC_seats
      available_2AC_seats
      available_general_seats
      available_id
      created_at
      dates
      id
      id_value
      occupied_1AC_seats
      occupied_2AC_seats
      occupied_general_seats
      reservation_id
      train_detail_id
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[reservations train_detail]
  end
end
