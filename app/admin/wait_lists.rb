ActiveAdmin.register WaitList do
  permit_params :pnr, :available_id, :berth_class, :reservation_id, :train_detail_id, :dates # Add any other parameters you need

  # Add a filter for passenger names
  filter :passengers_passenger_name_cont, as: :string, label: 'Passenger Name'

  # Define the index page to display the required columns
  index do
    selectable_column
    id_column
    column :pnr
    column :available_id
    column :berth_class
    column :train_detail_id
    column :reservation_id
    column :created_at
    column :updated_at
    actions
  end
end
