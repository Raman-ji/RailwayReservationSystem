class CreatePassengers < ActiveRecord::Migration[7.1]
  def change
    create_table :passengers do |t|
      t.string :passenger_name
      t.string :date_of_birth
      t.string :gender
      t.text :seat_number
      t.timestamps
    end
  end
end
