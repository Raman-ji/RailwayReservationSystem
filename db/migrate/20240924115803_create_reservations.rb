class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.date :date
      t.text :pnr
      t.string :berth_class
      t.text :ticket_status
      t.text :payment_status
      t.string :email
      t.integer :phone_number
      t.references :train_detail, null: false, foreign_key: true
      t.references :available, null: false, foreign_key: true

      t.timestamps
    end
  end
end
