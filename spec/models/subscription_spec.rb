require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:plan) }
    it { should validate_presence_of(:status) }
    
    describe 'only one active subscription per user' do
      let(:user) { create(:user) }
      let(:plan) { create(:plan) }
      
      context 'when user already has an active subscription' do
        before { create(:subscription, :active, user: user) }
        
        it 'prevents creating another active subscription' do
          subscription = build(:subscription, :active, user: user, plan: plan)
          expect(subscription).to_not be_valid
          expect(subscription.errors[:base]).to include('Usuário já possui uma assinatura ativa')
        end
      end
      
      context 'when user has no active subscription' do
        it 'allows creating an active subscription' do
          subscription = build(:subscription, :active, user: user, plan: plan)
          expect(subscription).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:plan) }
    it { should have_many(:invoices).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, active: 1, canceled: 2) }
  end

  describe '#activate!' do
    let(:user) { create(:user) }
    let(:plan) { create(:plan) }
    let(:subscription) { create(:subscription, user: user, plan: plan, status: :pending) }

    context 'when user has no active subscription' do
      it 'activates the subscription' do
        allow(Invoices::GenerateService).to receive(:call).and_return(
          OpenStruct.new(success?: true)
        )
        
        expect(subscription.activate!).to be_truthy
        expect(subscription.reload.status).to eq('active')
        expect(subscription.started_at).to be_present
      end

      it 'generates the first invoice' do
        expect(Invoices::GenerateService).to receive(:call).with(
          subscription: subscription,
          reference_date: anything
        )
        
        subscription.activate!
      end
    end

    context 'when user already has an active subscription' do
      before { create(:subscription, :active, user: user) }

      it 'returns false' do
        expect(subscription.activate!).to be false
      end
    end
  end

  describe '#cancel!' do
    context 'with active subscription' do
      let(:subscription) { create(:subscription, :active) }

      it 'cancels the subscription' do
        expect(subscription.cancel!).to be_truthy
        expect(subscription.reload.status).to eq('canceled')
        expect(subscription.canceled_at).to be_present
      end
    end

    context 'with non-active subscription' do
      let(:subscription) { create(:subscription, status: :pending) }

      it 'returns false' do
        expect(subscription.cancel!).to be false
      end
    end
  end
end
