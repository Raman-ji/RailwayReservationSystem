
FactoryBot.define do
  factory :available do
    dates { Faker::Date.forward(days: 30) }
    _2AC_available { rand(0..10) }
    _1AC_available { rand(0..5) }
    general_available { rand(20..100) }
    association :train_detail

    before(:create) do |available|
      available._2AC_available ||= available.train_detail.class_2a_count
      available._1AC_available ||= available.train_detail.class_1a_count
      available.general_available ||= available.train_detail.class_general_count
    end
  end
end
