class WaitList < ApplicationRecord
  belongs_to :train_detail
  belongs_to :reservation
  belongs_to :available
end
