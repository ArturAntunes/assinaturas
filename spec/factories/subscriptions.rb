FactoryBot.define do
  factory :subscription do
    user
    plan
    status { :pending }
    started_at { nil }
    canceled_at { nil }

    trait :active do
      status { :active }
      started_at { Time.current }
    end

    trait :canceled do
      status { :canceled }
      started_at { 1.month.ago }
      canceled_at { Time.current }
    end
  end
end
