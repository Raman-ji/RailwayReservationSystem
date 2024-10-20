require 'rails_helper'

RSpec.describe WaitList, type: :model do
  let(:wait_list) { create(:wait_list) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(wait_list).to be_valid
    end

    it 'is invalid without a berth_class' do
      wait_list.berth_class = nil
      expect(wait_list).not_to be_valid
    end

    it 'is invalid without a passenger_name' do
      wait_list.passenger_name = nil
      expect(wait_list).not_to be_valid
    end

    it 'is invalid without a dates' do
      wait_list.dates = nil
      expect(wait_list).not_to be_valid
    end
  end

  context 'associations' do
    it { should belong_to(:train_detail) }
    it { should belong_to(:reservation) }
    it { should belong_to(:available) }
    it { should belong_to(:passenger) }
  end
end
