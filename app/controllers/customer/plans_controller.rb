module Customer
  class PlansController < BaseController
    def index
      @plans = Plan.active.order(:price_cents)
      @current_subscription = current_user.active_subscription
    end
  end
end
