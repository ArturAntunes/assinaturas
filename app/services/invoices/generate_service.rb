module Invoices
  class GenerateService
    attr_reader :subscription, :reference_date

    def self.call(**args)
      new(**args).call
    end

    def initialize(subscription:, reference_date: Time.current)
      @subscription = subscription
      @reference_date = reference_date
    end

    def call
      return failure('Assinatura não está ativa') unless subscription.active?

      if invoice_already_exists?
        return failure('Já existe fatura para este mês')
      end

      create_invoice
    end

    private

    def invoice_already_exists?
      Invoice.exists?(
        subscription: subscription,
        reference_month: reference_month
      )
    end

    def reference_month
      @reference_month ||= reference_date.beginning_of_month
    end

    def due_date
      reference_date.to_date + 5.days
    end

    def create_invoice
      invoice = Invoice.create!(
        subscription: subscription,
        reference_month: reference_month,
        amount_cents: subscription.plan.price_cents,
        due_on: due_date,
        status: :open
      )

      success(invoice)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    def success(invoice)
      OpenStruct.new(success?: true, invoice: invoice, error: nil)
    end

    def failure(message)
      OpenStruct.new(success?: false, invoice: nil, error: message)
    end
  end
end
