FactoryBot.define do
  factory :train_detail do
    train_code { "P123" }
    from { Faker::Address.city }
    to { Faker::Address.city }
    days { %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].sample(3).join(', ') }
    departure_time { Faker::Time.forward(days: 5, period: :morning) }
    arrival_time { Faker::Time.forward(days: 5, period: :evening) }
    distance_km { rand(50..1500) }
    travel_time_hrs { rand(1..24) }
    class_2a_count { rand(0..10) }
    class_2a_price { rand(500..2000) }
    class_1a_count { rand(0..5) }
    class_1a_price { rand(1000..3000) }
    class_general_count { rand(50..200) }
    class_general_price { rand(100..500) }
    train_name { "#{Faker::Vehicle.make} Express" }
  end
end
