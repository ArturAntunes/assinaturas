class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?, :customer?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def customer?
    logged_in? && current_user.customer?
  end

  def require_login
    unless logged_in?
      flash[:alert] = 'Você precisa estar logado para acessar esta página'
      redirect_to login_path
    end
  end

  def require_admin
    unless admin?
      flash[:alert] = 'Acesso negado. Apenas administradores podem acessar esta página.'
      redirect_to root_path
    end
  end

  def require_customer
    unless customer?
      flash[:alert] = 'Acesso negado. Apenas clientes podem acessar esta página.'
      redirect_to root_path
    end
  end
end
