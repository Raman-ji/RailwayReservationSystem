class CreateAvailables < ActiveRecord::Migration[7.1]
  def change
    create_table :availables do |t|
      t.date :dates
      t.integer :_2AC_available
      t.integer :_1AC_available
      t.integer :general_available
      t.references :train_detail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
