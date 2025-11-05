module Admin
  class SubscriptionsController < BaseController
    def index
      @subscriptions = Subscription.includes(:user, :plan)
                                   .order(created_at: :desc)

      # Filtros
      @subscriptions = @subscriptions.where(status: params[:status]) if params[:status].present?
      @subscriptions = @subscriptions.where(plan_id: params[:plan_id]) if params[:plan_id].present?

      @subscriptions = @subscriptions.page(params[:page]).per(15)
      @plans = Plan.all # Para o filtro
    end

    def show
      @subscription = Subscription.includes(:user, :plan, invoices: []).find(params[:id])
    end

    def cancel
      @subscription = Subscription.find(params[:id])
      result = Subscriptions::CancelService.call(subscription: @subscription)

      if result.success?
        flash[:notice] = 'Assinatura cancelada com sucesso!'
      else
        flash[:alert] = result.error
      end

      redirect_to admin_subscription_path(@subscription)
    end
  end
end
