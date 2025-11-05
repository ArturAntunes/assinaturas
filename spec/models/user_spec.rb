require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:password).is_at_least(6) }
    
    it 'validates email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).to_not be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe 'associations' do
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:plans).through(:subscriptions) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(customer: 0, admin: 1) }
  end

  describe 'callbacks' do
    describe '#generate_api_token' do
      it 'generates api token before create' do
        user = build(:user, api_token: nil)
        user.save!
        expect(user.api_token).to be_present
        expect(user.api_token.length).to eq(40)
      end
    end
  end

  describe '#active_subscription' do
    let(:user) { create(:user) }
    
    context 'with active subscription' do
      let!(:subscription) { create(:subscription, :active, user: user) }
      
      it 'returns the active subscription' do
        expect(user.active_subscription).to eq(subscription)
      end
    end

    context 'without active subscription' do
      it 'returns nil' do
        expect(user.active_subscription).to be_nil
      end
    end
  end

  describe '#has_active_subscription?' do
    let(:user) { create(:user) }
    
    context 'with active subscription' do
      before { create(:subscription, :active, user: user) }
      
      it 'returns true' do
        expect(user.has_active_subscription?).to be true
      end
    end

    context 'without active subscription' do
      it 'returns false' do
        expect(user.has_active_subscription?).to be false
      end
    end
  end
end
