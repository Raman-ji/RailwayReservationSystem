class WaitList < ApplicationRecord
  belongs_to :train_detail
  belongs_to :reservation
  belongs_to :available

  serialize :passenger_names, coder: JSON
  serialize :wait_pnr, coder: JSON

  def self.ransackable_attributes(auth_object = nil)
    [
      "pnr",
      "available_id", 
      "berth_class", 
      "created_at", 
      "dates", 
      "id", 
      "id_value", 
      "reservation_id", 
      "train_detail_id", 
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["reservation", "available"]  # Adjust according to your actual associations
  end
  
end
