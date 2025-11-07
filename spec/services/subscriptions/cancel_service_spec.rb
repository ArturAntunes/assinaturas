require 'rails_helper'

RSpec.describe Subscriptions::CancelService do
  describe '#call' do
    let(:user) { create(:user) }
    let(:plan) { create(:plan) }
    let(:subscription) { create(:subscription, :active, user: user, plan: plan) }
    let(:service) { described_class.new(subscription: subscription) }

    context 'when subscription is active' do
      it 'cancels the subscription' do
        result = service.call
        
        expect(result.success?).to be true
        expect(subscription.reload.status).to eq('canceled')
        expect(subscription.canceled_at).to be_present
      end

      context 'with open invoices' do
        let!(:open_invoice) { create(:invoice, subscription: subscription, status: :open, reference_month: Date.current.beginning_of_month) }
        let!(:paid_invoice) { create(:invoice, :paid, subscription: subscription, reference_month: 1.month.ago.beginning_of_month) }

        it 'marks open invoices as expired' do
          service.call
          
          expect(open_invoice.reload.status).to eq('expired')
          expect(paid_invoice.reload.status).to eq('paid') # não altera pagas
        end
      end
    end

    context 'when subscription is not active' do
      let(:subscription) { create(:subscription, status: :pending) }

      it 'returns error' do
        result = service.call
        
        expect(result.success?).to be false
        expect(result.error).to eq('Assinatura não está ativa')
      end
    end
  end
end
