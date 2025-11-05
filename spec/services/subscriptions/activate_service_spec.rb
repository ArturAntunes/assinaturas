require 'rails_helper'

RSpec.describe Subscriptions::ActivateService do
  describe '#call' do
    let(:user) { create(:user) }
    let(:plan) { create(:plan) }
    let(:service) { described_class.new(user: user, plan: plan) }

    context 'when user has no active subscription' do
      context 'and plan is active' do
        it 'creates an active subscription' do
          result = service.call
          
          expect(result.success?).to be true
          expect(result.subscription).to be_persisted
          expect(result.subscription.status).to eq('active')
          expect(result.subscription.started_at).to be_present
        end

        it 'generates first invoice' do
          expect(Invoices::GenerateService).to receive(:call).and_return(
            OpenStruct.new(success?: true)
          )
          
          service.call
        end
      end

      context 'and plan is inactive' do
        let(:plan) { create(:plan, :inactive) }

        it 'returns error' do
          result = service.call
          
          expect(result.success?).to be false
          expect(result.error).to eq('Plano não está ativo')
        end
      end
    end

    context 'when user already has an active subscription' do
      before { create(:subscription, :active, user: user) }

      it 'returns error' do
        result = service.call
        
        expect(result.success?).to be false
        expect(result.error).to eq('Usuário já possui assinatura ativa')
      end
    end
  end
end
