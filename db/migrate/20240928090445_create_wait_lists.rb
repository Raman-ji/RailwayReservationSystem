class CreateWaitLists < ActiveRecord::Migration[7.1]
  def change
    create_table :wait_lists do |t|
      t.date :dates
      t.string :berth_class
      t.text :passenger_names
      t.text :wait_pnr
      t.references :train_detail, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.references :available, null: false, foreign_key: true

      t.timestamps
    end
  end
end
