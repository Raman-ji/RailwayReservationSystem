class TrainDetailsController < ApplicationController
  def new
    @train_detail = TrainDetail.new(departure_time: Time.now, arrival_time: Time.now)
  end

  def create
    @train_detail = TrainDetail.new(train_detail_params)
    if @train_detail.save
      redirect_to admin_train_details_path, notice: 'Train detail created successfully!'
    else
      render :new
    end
  end

  private

  def train_detail_params
    # Ensure you permit the attributes you want to allow
    params.require(:train_detail).permit(:train_code, :from, :to, :days, :departure_time, :arrival_time, :distance_km,
                                         :travel_time_hrs, :class_1a_count, :class_1a_price, :class_2a_count, :class_2a_price, :class_general_count, :class_general_price, :train_name)
  end
end
