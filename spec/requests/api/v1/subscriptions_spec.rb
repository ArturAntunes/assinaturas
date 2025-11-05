require 'rails_helper'

RSpec.describe 'Api::V1::Subscriptions', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{user.api_token}" } }

  describe 'POST /api/v1/subscriptions' do
    let(:plan) { create(:plan) }

    context 'with valid authentication' do
      context 'when user has no active subscription' do
        it 'creates a new subscription' do
          expect {
            post '/api/v1/subscriptions', params: { plan_id: plan.id }, headers: headers
          }.to change(Subscription, :count).by(1)
          
          expect(response).to have_http_status(:created)
          
          json = JSON.parse(response.body)
          expect(json['message']).to eq('Assinatura ativada com sucesso')
          expect(json['subscription']['status']).to eq('active')
        end
      end

      context 'when user already has an active subscription' do
        before { create(:subscription, :active, user: user) }

        it 'returns error' do
          post '/api/v1/subscriptions', params: { plan_id: plan.id }, headers: headers
          
          expect(response).to have_http_status(:unprocessable_entity)
          
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Usuário já possui assinatura ativa')
        end
      end

      context 'with invalid plan_id' do
        it 'returns not found error' do
          post '/api/v1/subscriptions', params: { plan_id: 9999 }, headers: headers
          
          expect(response).to have_http_status(:not_found)
          
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Plano não encontrado')
        end
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/subscriptions', params: { plan_id: plan.id }
        
        expect(response).to have_http_status(:unauthorized)
        
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Token inválido ou não fornecido')
      end
    end
  end

  describe 'GET /api/v1/subscriptions/me' do
    context 'with valid authentication' do
      context 'when user has active subscription' do
        let!(:subscription) { create(:subscription, :active, user: user) }
        let!(:invoice) { create(:invoice, subscription: subscription) }

        it 'returns subscription details with recent invoices' do
          get '/api/v1/subscriptions/me', headers: headers
          
          expect(response).to have_http_status(:success)
          
          json = JSON.parse(response.body)
          expect(json['subscription']).to be_present
          expect(json['subscription']['id']).to eq(subscription.id)
          expect(json['recent_invoices']).to be_an(Array)
        end
      end

      context 'when user has no active subscription' do
        it 'returns null subscription with message' do
          get '/api/v1/subscriptions/me', headers: headers
          
          expect(response).to have_http_status(:success)
          
          json = JSON.parse(response.body)
          expect(json['subscription']).to be_nil
          expect(json['message']).to eq('Nenhuma assinatura ativa')
        end
      end
    end
  end

  describe 'DELETE /api/v1/subscriptions/cancel' do
    context 'with valid authentication' do
      context 'when user has active subscription' do
        let!(:subscription) { create(:subscription, :active, user: user) }

        it 'cancels the subscription' do
          delete '/api/v1/subscriptions/cancel', headers: headers
          
          expect(response).to have_http_status(:success)
          
          json = JSON.parse(response.body)
          expect(json['message']).to eq('Assinatura cancelada com sucesso')
          expect(json['subscription']['status']).to eq('canceled')
        end
      end

      context 'when user has no active subscription' do
        it 'returns error' do
          delete '/api/v1/subscriptions/cancel', headers: headers
          
          expect(response).to have_http_status(:not_found)
          
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Nenhuma assinatura ativa para cancelar')
        end
      end
    end
  end
end
