require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response', :lobanov do
      get :index
      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({fruits: 'will_be_here'})
    end
  end
end