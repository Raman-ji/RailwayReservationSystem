class AddTrainNameToTrainDetail < ActiveRecord::Migration[7.1]
  def change
    add_column :train_details, :train_name, :string
  end
end
