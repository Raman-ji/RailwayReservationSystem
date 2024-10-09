class AddRefToReservation < ActiveRecord::Migration[7.1]
  def change
    add_reference :passengers, :reservation, null: false, foreign_key: true
  end
end
