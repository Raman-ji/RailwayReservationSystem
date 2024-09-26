class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.string :passenger_name
      t.integer :age
      t.string :gender
      t.date :date_of_birth
      t.date :date
      t.integer :pnr
      t.integer :seat_numbers
      t.string :berth_class
      t.string :ticket_status
      t.string :payment_status
      t.string :email
      t.integer :phone_number
      t.references :train_detail, null: false, foreign_key: true
      t.references :available, null: false, foreign_key: true

      t.timestamps
    end
  end
end
