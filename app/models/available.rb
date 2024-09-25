class Available < ApplicationRecord
  belongs_to :train_detail
  has_many :reservations

  before_create do
    self._2AC_available = self.train_detail.class_2a_count
    self._1AC_available = self.train_detail.class_1a_count
    self.general_available = self.train_detail.class_general_count
  end
end
