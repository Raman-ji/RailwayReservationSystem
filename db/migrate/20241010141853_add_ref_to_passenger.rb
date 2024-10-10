class AddRefToPassenger < ActiveRecord::Migration[7.1]
  def change
    add_reference :passengers, :wait_list, null: false, foreign_key: true
  end
end
