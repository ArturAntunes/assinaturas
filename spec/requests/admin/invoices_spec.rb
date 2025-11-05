require 'rails_helper'

RSpec.describe 'Admin::Invoices', type: :request do
  let(:admin) { create(:user, :admin) }
  
  before do
    post '/login', params: { email: admin.email, password: 'password123' }
  end

  describe 'GET /admin/invoices' do
    let(:subscription) { create(:subscription, :active) }
    let!(:invoice1) { create(:invoice, subscription: subscription, status: :open) }
    let!(:invoice2) { create(:invoice, :paid, subscription: subscription) }

    it 'lists all invoices' do
      get '/admin/invoices'
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Gerenciar Faturas')
    end

    context 'with status filter' do
      it 'filters by status' do
        get '/admin/invoices', params: { status: 'paid' }
        
        expect(response).to have_http_status(:success)
      end
    end

    context 'with month filter' do
      it 'filters by month in YYYY-MM format' do
        get '/admin/invoices', params: { month: '2025-06' }
        
        expect(response).to have_http_status(:success)
        expect(flash[:alert]).to be_nil
      end

      it 'filters by month matching current month' do
        current_month = Date.current.strftime('%Y-%m')
        get '/admin/invoices', params: { month: current_month }
        
        expect(response).to have_http_status(:success)
      end

      it 'handles invalid month format gracefully' do
        get '/admin/invoices', params: { month: 'invalid-date' }
        
        expect(response).to have_http_status(:success)
        expect(flash[:alert]).to eq('Formato de data inválido')
      end
    end
  end

  describe 'GET /admin/invoices/:id' do
    let(:subscription) { create(:subscription, :active) }
    let(:invoice) { create(:invoice, subscription: subscription) }

    it 'shows invoice details' do
      get "/admin/invoices/#{invoice.id}"
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Detalhes da Fatura ##{invoice.id}")
    end
  end
end
