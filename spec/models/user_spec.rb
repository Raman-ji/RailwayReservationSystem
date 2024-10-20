require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is invalid without a password' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: user.email)
      expect(user).not_to be_valid
    end

    it 'is invalid with an improperly formatted email' do
      user.email = 'invalidemail'
      expect(user).not_to be_valid
    end
  end

  context 'Devise modules' do
    it 'responds to database_authenticatable' do
      expect(User).to include(Devise::Models::DatabaseAuthenticatable)
    end

    it 'responds to recoverable' do
      expect(User).to include(Devise::Models::Recoverable)
    end

    it 'responds to rememberable' do
      expect(User).to include(Devise::Models::Rememberable)
    end

    it 'responds to validatable' do
      expect(User).to include(Devise::Models::Validatable)
    end
  end
end
