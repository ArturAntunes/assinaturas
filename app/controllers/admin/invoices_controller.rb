module Admin
  class InvoicesController < BaseController
    def index
      @invoices = Invoice.includes(subscription: [:user, :plan])
                         .order(created_at: :desc)

      # Filtros
      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      
      if params[:month].present?
        begin
          date = Date.strptime("#{params[:month]}-01", "%Y-%m-%d")
          @invoices = @invoices.by_month(date)
        rescue Date::Error, ArgumentError
          flash.now[:alert] = "Formato de data inválido"
        end
      end

      @invoices = @invoices.page(params[:page]).per(15)
    end

    def show
      @invoice = Invoice.includes(subscription: [:user, :plan]).find(params[:id])
    end
  end
end
