FactoryBot.define do
  factory :invoice do
    subscription
    reference_month { Date.current.beginning_of_month }
    amount_cents { subscription.plan.price_cents }
    due_on { Date.current + 5.days }
    status { :open }
    paid_at { nil }

    trait :paid do
      status { :paid }
      paid_at { Time.current }
    end

    trait :expired do
      status { :expired }
      due_on { 1.month.ago }
    end
  end
end
