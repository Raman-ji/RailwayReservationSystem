class TrainDetail < ApplicationRecord
  has_many :availables, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :seats, dependent: :destroy
  has_many :wait_lists, dependent: :destroy

  serialize :days, coder: JSON

  # starts with 1 to 3 uppercase letters followed by 1 to 4 digits
  validates :train_code,
            format: { with: /\A[A-Z]{1,3}\d{1,4}\z/, message: 'must be a valid Indian passenger train code' }

  with_options presence: true do
    validates :train_code, :train_name, :from, :to, :days, :departure_time, :arrival_time, :distance_km, :travel_time_hrs,
              :class_2a_count, :class_2a_price, :class_1a_count, :class_1a_price, :class_general_count, :class_general_price
  end

  before_create do
    self.from = from.titleize if from.present?
    self.to = to.titleize if to.present?
    self.train_name = train_name.titleize if train_name.present?
  end
end
