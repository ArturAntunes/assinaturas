class PagesController < ApplicationController
  def home
    if logged_in?
      redirect_to current_user.admin? ? admin_dashboard_path : customer_dashboard_path
    else
      @plans = Plan.active.order(:price_cents)
    end
  end
end
