FactoryBot.define do
  factory :wait_list do
    dates { Date.today }
    berth_class { '2AC' }
    passenger_name { Faker::Name.name }
    association :train_detail
    association :reservation
    association :available
    association :passenger
  end
end
