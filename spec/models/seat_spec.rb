require 'rails_helper'

RSpec.describe Seat, type: :model do
  subject { create(:seat) }

  it { should validate_presence_of(:dates) }
  it { should belong_to(:train_detail) }
  it { should belong_to(:available) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'serializations' do
    it 'serializes available_2AC_seats as JSON' do
      subject.available_2AC_seats = ["2A", "2B"]
      subject.save
      expect(subject.reload.available_2AC_seats).to eq(["2A", "2B"])
    end

    it 'serializes occupied_2AC_seats as JSON' do
      subject.occupied_2AC_seats = ["1A", "1B"]
      subject.save
      expect(subject.reload.occupied_2AC_seats).to eq(["1A", "1B"])
    end
  end
end
