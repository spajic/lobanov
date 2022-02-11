require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'GET #index' do
    it 'returns expected collection', :lobanov do
      get(:index)

      expect(response).to have_http_status(:ok)
      expect(json_body[:items].size).to eq(4)
    end
  end

  describe 'GET #show' do
    it 'returns expected resource', :lobanov do
      get(:show, params: {id: 2})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({name: 'lemon', color: 'yellow', weight: 50, seasonal: false})
    end
  end

  describe 'POST #create' do
    let(:apple) { {name: 'apple', color: 'green', weight: 150, seasonal: false} }
    it 'returns expected response with 201', :lobanov do
      post(:create, params: apple, as: :json)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PUT #update' do
    let(:apple) { {id: 1, name: 'apple', color: 'green', weight: 150, seasonal: false} }
    it 'returns expected response with 200 and empty body' do
      put(:update, params: apple)

      expect(response).to have_http_status(:ok)
    end
  end
end
