require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:subscription) }
    it { should validate_presence_of(:reference_month) }
    it { should validate_presence_of(:amount_cents) }
    it { should validate_numericality_of(:amount_cents).is_greater_than(0) }
    it { should validate_presence_of(:due_on) }
    it { should validate_presence_of(:status) }
    
    describe 'unique invoice per month' do
      let(:subscription) { create(:subscription, :active) }
      let(:reference_month) { Date.current.beginning_of_month }
      
      context 'when invoice already exists for the month' do
        before do
          create(:invoice, subscription: subscription, reference_month: reference_month)
        end
        
        it 'prevents creating another invoice for the same month' do
          invoice = build(:invoice, subscription: subscription, reference_month: reference_month)
          expect(invoice).to_not be_valid
          expect(invoice.errors[:reference_month]).to include('já possui fatura para este mês')
        end
      end
      
      context 'when no invoice exists for the month' do
        it 'allows creating invoice' do
          invoice = build(:invoice, subscription: subscription, reference_month: reference_month)
          expect(invoice).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:subscription) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(open: 0, paid: 1, expired: 2) }
  end

  describe 'scopes' do
    let!(:open_invoice) { create(:invoice, status: :open, due_on: 1.week.from_now) }
    let!(:paid_invoice) { create(:invoice, :paid) }
    let!(:expired_invoice) { create(:invoice, :expired) }
    let!(:overdue_invoice) { create(:invoice, status: :open, due_on: 1.week.ago) }

    describe '.open' do
      it 'returns open invoices' do
        expect(Invoice.open).to include(open_invoice, overdue_invoice)
        expect(Invoice.open).not_to include(paid_invoice, expired_invoice)
      end
    end

    describe '.paid' do
      it 'returns paid invoices' do
        expect(Invoice.paid).to include(paid_invoice)
        expect(Invoice.paid).not_to include(open_invoice, expired_invoice)
      end
    end

    describe '.overdue' do
      it 'returns overdue invoices' do
        expect(Invoice.overdue).to include(overdue_invoice)
        expect(Invoice.overdue).not_to include(open_invoice, paid_invoice, expired_invoice)
      end
    end
  end

  describe '#pay!' do
    context 'with open invoice and active subscription' do
      let(:subscription) { create(:subscription, :active) }
      let(:invoice) { create(:invoice, status: :open, subscription: subscription) }

      it 'marks invoice as paid' do
        expect(invoice.pay!).to be_truthy
        expect(invoice.reload.status).to eq('paid')
        expect(invoice.paid_at).to be_present
      end
    end

    context 'with open invoice but canceled subscription' do
      let(:subscription) { create(:subscription, :canceled) }
      let(:invoice) { create(:invoice, status: :open, subscription: subscription) }

      it 'returns false' do
        expect(invoice.pay!).to be false
        expect(invoice.reload.status).to eq('open')
      end
    end

    context 'with non-open invoice' do
      let(:invoice) { create(:invoice, :paid) }

      it 'returns false' do
        expect(invoice.pay!).to be false
      end
    end
  end

  describe '#can_be_paid?' do
    context 'when invoice is open and subscription is active' do
      let(:subscription) { create(:subscription, :active) }
      let(:invoice) { create(:invoice, status: :open, subscription: subscription) }

      it 'returns true' do
        expect(invoice.can_be_paid?).to be true
      end
    end

    context 'when invoice is open but subscription is canceled' do
      let(:subscription) { create(:subscription, :canceled) }
      let(:invoice) { create(:invoice, status: :open, subscription: subscription) }

      it 'returns false' do
        expect(invoice.can_be_paid?).to be false
      end
    end

    context 'when invoice is already paid' do
      let(:invoice) { create(:invoice, :paid) }

      it 'returns false' do
        expect(invoice.can_be_paid?).to be false
      end
    end
  end

  describe '#overdue?' do
    context 'when invoice is open and past due date' do
      let(:invoice) { create(:invoice, status: :open, due_on: 1.day.ago) }

      it 'returns true' do
        expect(invoice.overdue?).to be true
      end
    end

    context 'when invoice is open but not past due date' do
      let(:invoice) { create(:invoice, status: :open, due_on: 1.day.from_now) }

      it 'returns false' do
        expect(invoice.overdue?).to be false
      end
    end

    context 'when invoice is paid' do
      let(:invoice) { create(:invoice, :paid, due_on: 1.day.ago) }

      it 'returns false' do
        expect(invoice.overdue?).to be false
      end
    end
  end
end
