require 'rails_helper'

RSpec.describe 'Api::V1::Plans', type: :request do
  describe 'GET /api/v1/plans' do
    
    context 'with active plans' do
      before do
        Plan.destroy_all
      end
      
      let!(:active_plan1) { create(:plan, name: 'Basic', price_cents: 1000, active: true) }
      let!(:active_plan2) { create(:plan, name: 'Pro', price_cents: 2000, active: true) }
      let!(:inactive_plan) { create(:plan, name: 'Old', active: false) }

      it 'returns only active plans' do
        get '/api/v1/plans'
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        
        plan_names = json.map { |p| p['name'] }
        expect(plan_names).to include('Basic', 'Pro')
        expect(plan_names).not_to include('Old')
      end

      it 'returns plans ordered by price' do
        get '/api/v1/plans'
        
        json = JSON.parse(response.body)
        prices = json.map { |p| p['price_cents'] }
        
        expect(prices).to eq(prices.sort)
      end

      it 'includes formatted price' do
        get '/api/v1/plans'
        
        json = JSON.parse(response.body)
        first_plan = json.first
        
        expect(first_plan).to have_key('formatted_price')
        expect(first_plan['formatted_price']).to match(/R\$ \d+,\d{2}/)
      end
    end

    context 'with no active plans' do
      before do
        Plan.destroy_all
      end
      
      it 'returns empty array' do
        get '/api/v1/plans'
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json).to eq([])
      end
    end
  end
end
