class ReverseChangeDepartureAndArrivalTime < ActiveRecord::Migration[7.1]
  def up
    change_column :train_details, :departure_time, :time
    change_column :train_details, :arrival_time, :time
  end

  def down
    change_column :train_details, :departure_time, :datetime
    change_column :train_details, :arrival_time, :datetime
  end
end
