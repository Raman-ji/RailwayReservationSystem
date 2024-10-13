class WaitList < ApplicationRecord
  belongs_to :train_detail
  belongs_to :reservation
  belongs_to :available
  belongs_to :passenger

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
      "updated_at",
      "passengers_passenger_name" 
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["reservation", "available", "passengers"]  
  end
end
