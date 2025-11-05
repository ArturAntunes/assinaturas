module Subscriptions
  class CancelService
    attr_reader :subscription

    def self.call(**args)
      new(**args).call
    end

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      return failure('Assinatura não está ativa') unless subscription.active?

      cancel_subscription
    end

    private

    def cancel_subscription
      subscription.update!(
        status: :canceled,
        canceled_at: Time.current
      )

      success(subscription)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    def success(subscription)
      OpenStruct.new(success?: true, subscription: subscription, error: nil)
    end

    def failure(message)
      OpenStruct.new(success?: false, subscription: nil, error: message)
    end
  end
end
