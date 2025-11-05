module Subscriptions
  class ActivateService
    attr_reader :user, :plan

    def self.call(**args)
      new(**args).call
    end

    def initialize(user:, plan:)
      @user = user
      @plan = plan
    end

    def call
      return failure('Usuário já possui assinatura ativa') if user.has_active_subscription?
      return failure('Plano não está ativo') unless plan.active?

      create_subscription_and_first_invoice
    end

    private

    def create_subscription_and_first_invoice
      subscription = nil

      ActiveRecord::Base.transaction do
        subscription = create_subscription
        generate_first_invoice(subscription)
      end

      success(subscription)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    rescue StandardError => e
      failure("Erro ao ativar assinatura: #{e.message}")
    end

    def create_subscription
      Subscription.create!(
        user: user,
        plan: plan,
        status: :active,
        started_at: Time.current
      )
    end

    def generate_first_invoice(subscription)
      result = Invoices::GenerateService.call(
        subscription: subscription,
        reference_date: Time.current
      )

      raise StandardError, result.error unless result.success?
    end

    def success(subscription)
      OpenStruct.new(success?: true, subscription: subscription, error: nil)
    end

    def failure(message)
      OpenStruct.new(success?: false, subscription: nil, error: message)
    end
  end
end
