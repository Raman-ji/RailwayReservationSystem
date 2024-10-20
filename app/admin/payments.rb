ActiveAdmin.register Payment do
  permit_params :reservation_id, :payment_intent_id, :date, :train_id, :berth, :amount, :status, :currency, :passenger_name

  index do
    selectable_column
    id_column
    column :reservation
    column :payment_intent_id
    column :date
    column :train_id
    column :berth
    column :amount
    column :status
    column :currency
    column :passenger_name
    actions
  end

  form do |f|
    f.inputs do
      f.input :reservation
      f.input :payment_intent_id
      f.input :date, as: :datepicker
      f.input :train_id
      f.input :berth
      f.input :amount
      f.input :status
      f.input :currency
      f.input :passenger_name
    end
    f.actions
  end

  show do
    attributes_table do
      row :reservation
      row :payment_intent_id
      row :date
      row :train_id
      row :berth
      row :amount
      row :status
      row :currency
      row :passenger_name
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end



end
