class Available < ApplicationRecord
  belongs_to :train_detail
  has_many :reservations, dependent: :destroy
  has_many :wait_lists, dependent: :destroy
  has_one :seat, dependent: :destroy

  validates :dates, presence: true
  validates :_2AC_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :_1AC_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :general_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  before_validation :set_default_values

  def set_default_values
    self._2AC_available ||= 0
    self._1AC_available ||= 0
    self.general_available ||= 0
  end

  # initial value of available model
  before_create do
    self._2AC_available = train_detail.class_2a_count || 0
    self._1AC_available = train_detail.class_1a_count || 0
    self.general_available = train_detail.class_general_count || 0
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
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
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[reservations seat train_detail wait_lists]
  end
end
