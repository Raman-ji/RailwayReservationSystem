class AddRefToPassengers < ActiveRecord::Migration[7.1]
  def change
    add_reference :wait_lists, :passenger, null: false, foreign_key: true
  end
end
