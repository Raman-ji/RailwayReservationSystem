FactoryBot.define do
  factory :reservation do
    date { Date.today }
    berth_class { '2AC' }
    payment_status { { status: 'pending' } }
    email { Faker::Internet.email }
    phone_number { Faker::Number.number(digits: 10) }
    association :train_detail
    association :available

    after(:build) do |reservation|
      reservation.passengers << build(:passenger, reservation: reservation)
    end
  end
end
