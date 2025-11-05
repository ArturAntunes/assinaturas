module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users: User.customer.count,
        active_subscriptions: Subscription.active.count,
        total_revenue: Invoice.paid.sum(:amount_cents),
        pending_invoices: Invoice.open.count
      }

      @recent_subscriptions = Subscription.order(created_at: :desc).limit(5)
      @recent_invoices = Invoice.order(created_at: :desc).limit(5)
    end
  end
end
