module Api
  module V1
    class PlansController < BaseController
      skip_before_action :authenticate_token!, only: [:index]

      def index
        plans = Plan.active.order(:price_cents)
        
        render_success(
          plans.map do |plan|
            {
              id: plan.id,
              name: plan.name,
              periodicity: plan.periodicity,
              price_cents: plan.price_cents,
              formatted_price: plan.formatted_price
            }
          end
        )
      end
    end
  end
end
