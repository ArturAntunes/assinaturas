class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = :customer

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = 'Conta criada com sucesso!'
      redirect_to customer_dashboard_path
    else
      flash.now[:alert] = 'Erro ao criar conta'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
