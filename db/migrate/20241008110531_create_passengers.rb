class CreatePassengers < ActiveRecord::Migration[7.1]
  def change
    create_table :passengers do |t|
      t.string :passenger_name
      t.string :date_of_birth
      t.string :gender
      t.integer :seat_number
      t.integer :pnr
      t.string :ticket_status
      t.timestamps
    end
  end
end
