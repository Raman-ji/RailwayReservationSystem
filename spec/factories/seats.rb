FactoryBot.define do
  factory :seat do
    dates { Faker::Date.forward(days: 30) }
    available_2AC_seats { [] }
    occupied_2AC_seats { [] }
    available_1AC_seats { [] }
    occupied_1AC_seats { [] }
    available_general_seats { [] }
    occupied_general_seats { [] }
    association :train_detail
    association :available

    before(:create) do |seat|
      seat.available_2AC_seats ||= []
      seat.occupied_2AC_seats ||= []
      seat.available_1AC_seats ||= []
      seat.occupied_1AC_seats ||= []
      seat.available_general_seats ||= []
      seat.occupied_general_seats ||= []
    end
  end
end
