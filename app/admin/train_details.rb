ActiveAdmin.register TrainDetail do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :train_code, :from, :to, :days, :departure_time, :arrival_time, :distance_km, :travel_time_hrs, :class_2a_count, :class_2a_price, :class_1a_count, :class_1a_price, :class_general_count, :class_general_price, :train_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:train_code, :from, :to, :days, :departure_time, :arrival_time, :distance_km, :travel_time_hrs, :class_2a_count, :class_2a_price, :class_1a_count, :class_1a_price, :class_general_count, :class_general_price, :train_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end


  permit_params :train_code, :train_name, :from, :to, :days, 
                :departure_time, :arrival_time, :distance_km, 
                :travel_time_hrs, :class_1a_count, :class_1a_price, 
                :class_2a_count, :class_2a_price, 
                :class_general_count, :class_general_price

  form do |f|
    f.inputs do
      f.input :train_code
      f.input :train_name
      f.input :from
      f.input :to
      f.input :days
      f.input :departure_time, as: :time_select, ignore_date: true
      f.input :arrival_time, as: :time_select, ignore_date: true
      f.input :distance_km
      f.input :travel_time_hrs
      f.input :class_1a_count
      f.input :class_1a_price
      f.input :class_2a_count
      f.input :class_2a_price
      f.input :class_general_count
      f.input :class_general_price
    end
    f.actions
  end
end
