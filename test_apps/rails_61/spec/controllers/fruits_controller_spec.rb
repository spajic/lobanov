require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'GET #show' do
    it 'returns expected resource', :lobanov do
      get(:show, params: {id: 2})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({color: 'yellow'})
    end
  end
end