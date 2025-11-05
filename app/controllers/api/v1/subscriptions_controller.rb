module Api
  module V1
    class SubscriptionsController < BaseController
      def create
        plan = Plan.find_by(id: params[:plan_id])
        
        unless plan
          return render_error('Plano não encontrado', :not_found)
        end

        result = Subscriptions::ActivateService.call(
          user: current_user,
          plan: plan
        )

        if result.success?
          render_success(
            {
              message: 'Assinatura ativada com sucesso',
              subscription: subscription_json(result.subscription)
            },
            :created
          )
        else
          render_error(result.error)
        end
      end

      def me
        subscription = current_user.active_subscription
        
        if subscription
          invoices = subscription.invoices
                                .order(created_at: :desc)
                                .limit(5)
          
          render_success(
            {
              subscription: subscription_json(subscription),
              recent_invoices: invoices.map { |i| invoice_json(i) }
            }
          )
        else
          render_success(
            {
              subscription: nil,
              message: 'Nenhuma assinatura ativa'
            }
          )
        end
      end

      def cancel
        subscription = current_user.active_subscription
        
        unless subscription
          return render_error('Nenhuma assinatura ativa para cancelar', :not_found)
        end

        result = Subscriptions::CancelService.call(subscription: subscription)

        if result.success?
          render_success(
            {
              message: 'Assinatura cancelada com sucesso',
              subscription: subscription_json(result.subscription)
            }
          )
        else
          render_error(result.error)
        end
      end

      private

      def subscription_json(subscription)
        {
          id: subscription.id,
          status: subscription.status,
          started_at: subscription.started_at,
          plan: {
            id: subscription.plan.id,
            name: subscription.plan.name,
            periodicity: subscription.plan.periodicity,
            price_cents: subscription.plan.price_cents
          }
        }
      end

      def invoice_json(invoice)
        {
          id: invoice.id,
          reference_month: invoice.reference_month,
          amount_cents: invoice.amount_cents,
          due_on: invoice.due_on,
          status: invoice.status,
          paid_at: invoice.paid_at
        }
      end
    end
  end
end
