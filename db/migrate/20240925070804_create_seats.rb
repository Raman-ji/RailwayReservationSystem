class CreateSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :seats do |t|
      t.date :dates
      t.text :available_2AC_seats
      t.text :occupied_2AC_seats
      t.text :available_1AC_seats
      t.text :occupied_1AC_seats
      t.text :available_general_seats
      t.text :occupied_general_seats
      t.references :train_detail, null: false, foreign_key: true
      t.references :available, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
