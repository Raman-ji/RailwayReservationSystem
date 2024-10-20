class Payment < ApplicationRecord
  belongs_to :reservation
  def self.ransackable_associations(auth_object = nil)
    ["reservation"]
  end
  def self.ransackable_attributes(auth_object = nil)
    ["payment_intent_id", "date", "train_id", "berth", "amount", "status", "currency", "passenger_name", "reservation_id", "created_at", "updated_at"]
  end
end
