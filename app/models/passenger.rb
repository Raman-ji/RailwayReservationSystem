class Passenger < ApplicationRecord
  serialize :seat_number, coder: JSON
  belongs_to :reservations
end
