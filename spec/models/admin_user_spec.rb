require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  let(:admin_user) { create(:admin_user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(admin_user).to be_valid
    end

    it 'is invalid without an email' do
      admin_user.email = nil
      expect(admin_user).not_to be_valid
    end

    it 'is invalid without a password' do
      admin_user.password = nil
      expect(admin_user).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      create(:admin_user, email: admin_user.email)
      expect(admin_user).not_to be_valid
    end

    it 'is invalid with an improperly formatted email' do
      admin_user.email = 'invalidemail'
      expect(admin_user).not_to be_valid
    end
  end

  context 'Devise modules' do
    it 'responds to database_authenticatable' do
      expect(AdminUser).to include(Devise::Models::DatabaseAuthenticatable)
    end

    it 'responds to recoverable' do
      expect(AdminUser).to include(Devise::Models::Recoverable)
    end

    it 'responds to rememberable' do
      expect(AdminUser).to include(Devise::Models::Rememberable)
    end

    it 'responds to validatable' do
      expect(AdminUser).to include(Devise::Models::Validatable)
    end
  end
end
