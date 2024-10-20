class WaitList < ApplicationRecord
  belongs_to :train_detail
  belongs_to :reservation
  belongs_to :available
  belongs_to :passenger

  validates :berth_class, :passenger_name, :dates, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      pnr
      available_id
      berth_class
      created_at
      dates
      id
      id_value
      reservation_id
      train_detail_id
      updated_at
      passengers_passenger_name
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[reservation available passengers]
  end
end
