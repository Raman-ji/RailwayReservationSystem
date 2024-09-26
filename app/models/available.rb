class Available < ApplicationRecord
  belongs_to :train_detail
  has_many :reservations, dependent: :destroy
  has_one :seat, dependent: :destroy

  # initial value of available model
  before_create do
    self._2AC_available = self.train_detail.class_2a_count
    self._1AC_available = self.train_detail.class_1a_count
    self.general_available = self.train_detail.class_general_count
  end
end
