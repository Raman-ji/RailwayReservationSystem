class RenameDayToTrainDetail < ActiveRecord::Migration[7.1]
  def change
    rename_column :train_details, :day, :days
  end
end
