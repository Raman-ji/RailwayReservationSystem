class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.integer :reservation_id
      t.string :payment_intent_id
      t.date :date
      t.integer :train_id
      t.string :berth
      t.decimal :amount
      t.string :status
      t.string :currency
      t.text :passenger_name
      t.timestamps
    end
  end
end
