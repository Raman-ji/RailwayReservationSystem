class ChangeDayColumnTypeInTraindetail < ActiveRecord::Migration[7.1]
  def change
    def change
      change_column :traindetails, :day, :text
    end
  end
end
