module Admin
  class PlansController < BaseController
    before_action :set_plan, only: [:show, :edit, :update, :destroy, :toggle_active]

    def index
      @plans = Plan.order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
    end

    def new
      @plan = Plan.new
    end

    def create
      @plan = Plan.new(plan_params)

      if @plan.save
        flash[:notice] = 'Plano criado com sucesso!'
        redirect_to admin_plans_path
      else
        flash.now[:alert] = 'Erro ao criar plano'
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @plan.update(plan_params)
        flash[:notice] = 'Plano atualizado com sucesso!'
        redirect_to admin_plans_path
      else
        flash.now[:alert] = 'Erro ao atualizar plano'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @plan.subscriptions.exists?
        flash[:alert] = 'Não é possível excluir um plano que possui assinaturas'
      elsif @plan.destroy
        flash[:notice] = 'Plano excluído com sucesso!'
      else
        flash[:alert] = 'Erro ao excluir plano'
      end

      redirect_to admin_plans_path
    end

    def toggle_active
      @plan.update(active: !@plan.active)
      flash[:notice] = "Plano #{@plan.active? ? 'ativado' : 'desativado'} com sucesso!"
      redirect_to admin_plans_path
    end

    private

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params.require(:plan).permit(:name, :periodicity, :price_cents, :active)
    end
  end
end
