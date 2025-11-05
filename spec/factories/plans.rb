FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.word.capitalize }
    periodicity { :monthly }
    price_cents { rand(1000..10000) }
    active { true }

    trait :monthly do
      periodicity { :monthly }
    end

    trait :quarterly do
      periodicity { :quarterly }
    end

    trait :inactive do
      active { false }
    end
  end
end
