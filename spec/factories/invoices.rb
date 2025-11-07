FactoryBot.define do
  factory :invoice do
    association :subscription, factory: :subscription, strategy: :create
    
    sequence(:reference_month) { |n| (Date.current - n.months).beginning_of_month }
    
    due_on { reference_month + 5.days }
    status { :open }
    paid_at { nil }
    
    after(:build) do |invoice|
      invoice.amount_cents ||= invoice.subscription.plan.price_cents
    end

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
