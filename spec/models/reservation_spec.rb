require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:reservation) { create(:reservation) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(reservation).to be_valid
    end

    it 'is invalid without a berth_class' do
      reservation.berth_class = nil
      expect(reservation).not_to be_valid
    end

    it 'is invalid without an email' do
      reservation.email = nil
      expect(reservation).not_to be_valid
    end

    it 'is invalid with an incorrect phone number' do
      reservation.phone_number = '12345'
      expect(reservation).not_to be_valid
    end
  end

  context 'associations' do
    it 'has many passengers' do
      expect(reservation.passengers).not_to be_empty
    end

    it 'belongs to a train detail' do
      expect(reservation.train_detail).to be_present
    end

    it 'belongs to an available record' do
      expect(reservation.available).to be_present
    end
  end
end
