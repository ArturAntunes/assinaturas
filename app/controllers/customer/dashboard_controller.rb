module Customer
  class DashboardController < BaseController
    def index
      @subscription = current_user.active_subscription
      @recent_invoices = current_user.subscriptions
                                     .flat_map(&:invoices)
                                     .sort_by(&:created_at)
                                     .reverse
                                     .first(5)
    end
  end
end
