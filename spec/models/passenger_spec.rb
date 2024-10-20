require 'rails_helper'

RSpec.describe Passenger, type: :model do
  let(:reservation) { create(:reservation) }

  context 'validations' do
    it 'is valid with valid attributes' do
      passenger = build(:passenger, reservation: reservation)
      expect(passenger).to be_valid
    end

    it 'is invalid without a passenger_name' do
      passenger = build(:passenger, passenger_name: nil)
      expect(passenger).not_to be_valid
      expect(passenger.errors[:passenger_name]).to include("can't be blank")
    end

    it 'is invalid without a date_of_birth' do
      passenger = build(:passenger, date_of_birth: nil)
      expect(passenger).not_to be_valid
      expect(passenger.errors[:date_of_birth]).to include("can't be blank")
    end

    it 'is invalid with a future date_of_birth' do
      passenger = build(:passenger, date_of_birth: (Date.today + 1.day).to_s)
      expect(passenger).not_to be_valid
      expect(passenger.errors[:date_of_birth]).to include('cannot be in the future.')
    end

    it 'is invalid if date_of_birth is more than 110 years ago' do
      passenger = build(:passenger, date_of_birth: (Date.today - 111.years).to_s)
      expect(passenger).not_to be_valid
      expect(passenger.errors[:date_of_birth]).to include('cannot be more than 110 years ago.')
    end
  end

  context 'callbacks' do
    it 'titleizes the passenger_name before save' do
      passenger = create(:passenger, passenger_name: 'john doe')
      expect(passenger.passenger_name).to eq('John Doe')
    end

    it 'generates a unique PNR before save' do
      passenger = create(:passenger)
      expect(passenger.pnr).not_to be_nil
    end
  end

  context 'methods' do
    it 'generates a unique PNR' do
      passenger = build(:passenger)
      passenger.generate_pnr
      expect(passenger.pnr).to be_a(Integer)
      expect(passenger.pnr.to_s.length).to eq(10)
    end

    it 'validates date_of_birth correctly' do
      passenger = build(:passenger, date_of_birth: (Date.today - 120.years).to_s)
      passenger.valid?
      expect(passenger.errors[:date_of_birth]).to include('cannot be more than 110 years ago.')
    end
  end
end
