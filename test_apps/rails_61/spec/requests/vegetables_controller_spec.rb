require 'rails_helper'

RSpec.describe Api::V6::VegetablesController, type: :request do
  describe 'GET #show' do
    it 'returns expected resource', :lobanov do
      get('/api/v6/vegetables/2?q=with_null_name')

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({ color: 'yellow', name: nil, weight: 50, seasonal: false })
    end
  end
end