module Customer
  class SubscriptionsController < BaseController
    def create
      plan = Plan.find(params[:plan_id])
      result = Subscriptions::ActivateService.call(user: current_user, plan: plan)

      if result.success?
        flash[:notice] = 'Assinatura ativada com sucesso!'
        redirect_to customer_dashboard_path
      else
        flash[:alert] = result.error
        redirect_to customer_plans_path
      end
    end

    def show
      @subscription = current_user.subscriptions.find(params[:id])
      @invoices = @subscription.invoices.order(created_at: :desc)
    end

    def cancel
      @subscription = current_user.subscriptions.find(params[:id])
      result = Subscriptions::CancelService.call(subscription: @subscription)

      if result.success?
        flash[:notice] = 'Assinatura cancelada com sucesso!'
      else
        flash[:alert] = result.error
      end

      redirect_to customer_dashboard_path
    end
  end
end
