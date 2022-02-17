require 'rails_helper'

RSpec.describe Fruits::ReviewsController, type: :controller do
  describe 'GET #show' do
    it 'returns expected review', :lobanov do
      get(:show, params: {fruit_id: 1, id: 1})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({text: 'review #1', positive: true})
    end
  end
end