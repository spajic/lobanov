require 'rails_helper'

RSpec.describe FruitsController, type: :request do
  describe 'GET #show' do
    it 'returns expected resource', :lobanov do
      get('/wapi/fruits/2')

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({color: 'yellow', name: 'lemon', seasonal: false, weight: 50})
    end
  end
end