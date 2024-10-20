require 'rails_helper'

RSpec.describe Available, type: :model do
  describe 'associations' do
    it { should belong_to(:train_detail) }
    it { should have_many(:reservations).dependent(:destroy) }
    it { should have_many(:wait_lists).dependent(:destroy) }
    it { should have_one(:seat).dependent(:destroy) }
  end

  describe 'callbacks' do
    let(:train_detail) { create(:train_detail) }
    let(:available) { build(:available, train_detail: train_detail) }

    context 'before_create' do
      it 'sets initial availability from train_detail' do
        available.run_callbacks(:create) { available.save }

        expect(available._2AC_available).to eq(train_detail.class_2a_count)
        expect(available._1AC_available).to eq(train_detail.class_1a_count)
        expect(available.general_available).to eq(train_detail.class_general_count)
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:dates) }
    it { should validate_numericality_of(:_2AC_available).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:_1AC_available).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:general_available).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'class methods' do
    context '.ransackable_attributes' do
      it 'returns the correct ransackable attributes' do
        expected_attributes = %w[
          _1AC_available
          _2AC_available
          created_at
          dates
          general_available
          id
          id_value
          train_detail_id
          updated_at
        ]
        expect(Available.ransackable_attributes).to match_array(expected_attributes)
      end
    end

    context '.ransackable_associations' do
      it 'returns the correct ransackable associations' do
        expected_associations = %w[reservations seat train_detail wait_lists]
        expect(Available.ransackable_associations).to match_array(expected_associations)
      end
    end
  end
end
