require 'rails_helper'

RSpec.describe TrainDetail, type: :model do
  describe 'associations' do
    it { should have_many(:availables).dependent(:destroy) }
    it { should have_many(:reservations).dependent(:destroy) }
    it { should have_many(:seats).dependent(:destroy) }
    it { should have_many(:wait_lists).dependent(:destroy) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { should validate_presence_of(:train_code) }
      it { should validate_presence_of(:train_name) }
      it { should validate_presence_of(:from) }
      it { should validate_presence_of(:to) }
      it { should validate_presence_of(:days) }
      it { should validate_presence_of(:departure_time) }
      it { should validate_presence_of(:arrival_time) }
      it { should validate_presence_of(:distance_km) }
      it { should validate_presence_of(:travel_time_hrs) }
      it { should validate_presence_of(:class_1a_count) }
      it { should validate_presence_of(:class_1a_price) }
      it { should validate_presence_of(:class_2a_count) }
      it { should validate_presence_of(:class_2a_price) }
      it { should validate_presence_of(:class_general_count) }
      it { should validate_presence_of(:class_general_price) }
    end

    context 'format validations' do
      let(:valid_train) {
        TrainDetail.new(
          train_code: 'P420',
          train_name: 'Rajdhani Express',
          from: 'Mumbai',
          to: 'Delhi',
          days: 'Mon',
          departure_time: Time.now,
          arrival_time: Time.now + 2.hours,
          distance_km: 1500,
          travel_time_hrs: 24,
          class_1a_count: 20,
          class_1a_price: 3000,
          class_2a_count: 50,
          class_2a_price: 1500,
          class_general_count: 100,
          class_general_price: 500
        )
      }

      let(:invalid_train) { TrainDetail.new(train_code: 'abc1234') }
      it 'validates format of train_code' do
        expect(valid_train).to be_valid
        expect(invalid_train).not_to be_valid
        expect(invalid_train.errors[:train_code]).to include('must be a valid Indian passenger train code')
      end
    end
  end

  describe 'callbacks' do
    let(:train) { build(:train_detail, from: 'mumbai', to: 'delhi', train_name: 'rajdhani express') }

    context 'before_create' do
      it 'titleizes from, to, and train_name' do
        train.run_callbacks(:create) do
          train.save
        end

        expect(train.from).to eq('Mumbai')
        expect(train.to).to eq('Delhi')
        expect(train.train_name).to eq('Rajdhani Express')
      end

      it 'sets class prices to 0 if they are nil or negative' do
        train.class_1a_price = -1
        train.class_2a_price = nil
        train.class_general_price = -5
        train.run_callbacks(:create) do
          train.save
        end

        expect(train.class_1a_price).to eq(0)
        expect(train.class_2a_price).to eq(0)
        expect(train.class_general_price).to eq(0)
      end

      it 'sets departure_time and arrival_time to current time if nil' do
        train.departure_time = nil
        train.arrival_time = nil
        train.run_callbacks(:create) do
          train.save
        end

        expect(train.departure_time).to be_within(2.seconds).of(Time.current)
        expect(train.arrival_time).to be_within(2.seconds).of(Time.current)
      end
    end
  end

  describe 'class methods' do
    context '.ransackable_attributes' do
      it 'returns the correct ransackable attributes' do
        expected_attributes = %w[
          arrival_time class_1a_count class_1a_price class_2a_count class_2a_price
          class_general_count class_general_price created_at days departure_time
          distance_km from id id_value to train_code train_name travel_time_hrs updated_at
        ]
        expect(TrainDetail.ransackable_attributes).to match_array(expected_attributes)
      end
    end

    context '.ransackable_associations' do
      it 'returns the correct ransackable associations' do
        expected_associations = %w[availables reservations seats wait_lists]
        expect(TrainDetail.ransackable_associations).to match_array(expected_associations)
      end
    end
  end
end
