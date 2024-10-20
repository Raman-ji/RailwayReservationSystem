FactoryBot.define do
  factory :passenger do
    passenger_name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(min_age: 5, max_age: 100) }
    gender { %w[Male Female].sample }
    seat_number { Faker::Number.between(from: 1, to: 50) }
    ticket_status { "Confirmed" }
    reservation
  end
end
