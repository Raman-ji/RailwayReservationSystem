class Seat < ApplicationRecord
  belongs_to :train_detail
  belongs_to :available
  belongs_to :reservation

  serialize :available_2AC_seats, coder: JSON
  serialize :occupied_2AC_seats, coder: JSON
  serialize :available_1AC_seats, coder: JSON
  serialize :occupied_1AC_seats, coder: JSON
  serialize :available_general_seats, coder: JSON
  serialize :occupied_general_seats, coder: JSON

end
