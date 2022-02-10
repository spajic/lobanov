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
end