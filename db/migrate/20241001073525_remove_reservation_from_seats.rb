class RemoveReservationFromSeats < ActiveRecord::Migration[7.1]
  def change
    remove_reference :seats, :reservation, null: false, foreign_key: true
  end
end
