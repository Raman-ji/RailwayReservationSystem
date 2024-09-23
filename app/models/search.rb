class Search < ApplicationRecord
  validates :city, presence: true
  before_create do
    self.city = city.titleize if city.present?
  end
end
