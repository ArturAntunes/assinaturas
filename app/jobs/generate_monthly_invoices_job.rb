class GenerateMonthlyInvoicesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "=== Iniciando geração mensal de faturas ==="
    
    generated_count = 0
    errors_count = 0

    Subscription.active.includes(:plan, :user).find_each do |subscription|
      result = generate_invoice_for_subscription(subscription)
      
      if result.success?
        generated_count += 1
        Rails.logger.info "Fatura gerada para assinatura ##{subscription.id}"
      else
        errors_count += 1
        Rails.logger.error "Erro ao gerar fatura para assinatura ##{subscription.id}: #{result.error}"
      end
    end

    Rails.logger.info "=== Finalizado: #{generated_count} faturas geradas, #{errors_count} erros ==="
  end

  private

  def generate_invoice_for_subscription(subscription)
    Invoices::GenerateService.call(
      subscription: subscription,
      reference_date: Time.current
    )
  end
end
