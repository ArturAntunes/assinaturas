class ExpireOverdueInvoicesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "=== Verificando faturas vencidas ==="
    
    expired_count = 0

    Invoice.overdue.find_each do |invoice|
      if invoice.mark_as_expired!
        expired_count += 1
        Rails.logger.info "Fatura ##{invoice.id} marcada como expirada"
      end
    end

    Rails.logger.info "=== Finalizado: #{expired_count} faturas marcadas como expiradas ==="
  end
end
