module Api
  module V1
    class InvoicesController < BaseController
      def index
        invoices = Invoice.joins(subscription: :user)
                         .where(subscriptions: { user_id: current_user.id })
                         .order(created_at: :desc)
        
        render_success(
          invoices.map { |invoice| invoice_json(invoice) }
        )
      end

      def show
        invoice = Invoice.joins(subscription: :user)
                        .where(subscriptions: { user_id: current_user.id })
                        .find_by(id: params[:id])

        unless invoice
          return render_error('Fatura não encontrada', :not_found)
        end

        render_success(invoice_json(invoice))
      end

      def pay
        invoice = Invoice.joins(subscription: :user)
                        .where(subscriptions: { user_id: current_user.id })
                        .find_by(id: params[:id])

        unless invoice
          return render_error('Fatura não encontrada', :not_found)
        end
        
        unless invoice.subscription.active?
          return render_error('Não é possível pagar fatura de assinatura cancelada')
        end

        if invoice.pay!
          render_success(
            {
              message: 'Pagamento registrado com sucesso',
              invoice: {
                id: invoice.id,
                status: invoice.status,
                paid_at: invoice.paid_at
              }
            }
          )
        else
          render_error('Não foi possível processar o pagamento')
        end
      end

      private

      def invoice_json(invoice)
        {
          id: invoice.id,
          reference_month: invoice.reference_month,
          amount_cents: invoice.amount_cents,
          formatted_amount: invoice.formatted_amount,
          due_on: invoice.due_on,
          status: invoice.status,
          paid_at: invoice.paid_at,
          can_be_paid: invoice.can_be_paid?,
          subscription: {
            id: invoice.subscription.id,
            status: invoice.subscription.status,
            plan_name: invoice.subscription.plan.name
          }
        }
      end
    end
  end
end
