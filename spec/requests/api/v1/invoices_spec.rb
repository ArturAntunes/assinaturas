require 'rails_helper'

RSpec.describe 'Api::V1::Invoices', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{user.api_token}" } }

  describe 'GET /api/v1/invoices' do
    context 'with valid authentication' do
      let(:subscription) { create(:subscription, :active, user: user) }
      let!(:invoice1) { create(:invoice, subscription: subscription) }
      let!(:invoice2) { create(:invoice, :paid, subscription: subscription) }

      it 'returns user invoices' do
        get '/api/v1/invoices', headers: headers
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.first).to have_key('id')
        expect(json.first).to have_key('status')
        expect(json.first).to have_key('can_be_paid')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/invoices'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/invoices/:id' do
    context 'with valid authentication' do
      let(:subscription) { create(:subscription, :active, user: user) }
      let(:invoice) { create(:invoice, subscription: subscription) }

      it 'returns invoice details' do
        get "/api/v1/invoices/#{invoice.id}", headers: headers
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json['id']).to eq(invoice.id)
        expect(json['subscription']['plan_name']).to be_present
      end
    end

    context 'with non-existent invoice' do
      it 'returns not found' do
        get '/api/v1/invoices/9999', headers: headers
        
        expect(response).to have_http_status(:not_found)
        
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Fatura não encontrada')
      end
    end
  end

  describe 'POST /api/v1/invoices/:id/pay' do
    context 'with open invoice and active subscription' do
      let(:subscription) { create(:subscription, :active, user: user) }
      let(:invoice) { create(:invoice, subscription: subscription, status: :open) }

      it 'marks invoice as paid' do
        post "/api/v1/invoices/#{invoice.id}/pay", headers: headers
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Pagamento registrado com sucesso')
        expect(json['invoice']['status']).to eq('paid')
      end
    end

    context 'with canceled subscription' do
      let(:subscription) { create(:subscription, :canceled, user: user) }
      let(:invoice) { create(:invoice, subscription: subscription, status: :open) }

      it 'returns error' do
        post "/api/v1/invoices/#{invoice.id}/pay", headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Não é possível pagar fatura de assinatura cancelada')
      end
    end
  end
end
