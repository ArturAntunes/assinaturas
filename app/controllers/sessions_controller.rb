class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Bem-vindo(a), #{user.name}!"
      
      redirect_to after_login_path(user)
    else
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Você saiu com sucesso'
    redirect_to root_path
  end

  private

  def after_login_path(user)
    if user.admin?
      admin_dashboard_path
    else
      customer_dashboard_path
    end
  end
end
