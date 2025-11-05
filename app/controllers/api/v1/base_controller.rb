module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_token!

      private

      def authenticate_token!
        token = request.headers['Authorization']&.gsub('Bearer ', '')
        
        @current_user = User.find_by(api_token: token)

        unless @current_user
          render json: { error: 'Token inválido ou não fornecido' }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end

      def render_success(data, status = :ok)
        render json: data, status: status
      end
    end
  end
end
