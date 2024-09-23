class CreateTrainDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :train_details do |t|
      t.string :train_code
      t.string :from
      t.string :to
      t.text :day
      t.datetime :departure_time
      t.datetime :arrival_time
      t.integer :distance_km
      t.integer :travel_time_hrs
      t.integer :class_2a_count
      t.integer :class_2a_price
      t.integer :class_1a_count
      t.integer :class_1a_price
      t.integer :class_general_count
      t.integer :class_general_price

      t.timestamps
    end
  end
end
