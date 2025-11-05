module Customer
  class InvoicesController < BaseController
    def index
      @invoices = current_user.subscriptions
                              .flat_map(&:invoices)
                              .sort_by(&:created_at)
                              .reverse
      
      @invoices = Kaminari.paginate_array(@invoices).page(params[:page]).per(10)
    end

    def show
      @invoice = Invoice.joins(subscription: :user)
                        .where(subscriptions: { user_id: current_user.id })
                        .find(params[:id])
    end

    def pay
      @invoice = Invoice.joins(subscription: :user)
                        .where(subscriptions: { user_id: current_user.id })
                        .find(params[:id])

      if !@invoice.subscription.active?
        flash[:alert] = 'Não é possível pagar fatura de assinatura cancelada'
      elsif @invoice.pay!
        flash[:notice] = 'Pagamento registrado com sucesso!'
      else
        flash[:alert] = 'Não foi possível processar o pagamento'
      end

      redirect_to customer_invoice_path(@invoice)
    end
  end
end
