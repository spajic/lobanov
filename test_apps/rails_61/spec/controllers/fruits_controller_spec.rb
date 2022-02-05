require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'GET #show' do
    it 'returns expected response', :lobanov do
      get(:show, params: {id: 1})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({color: nil})
    end
  end
end