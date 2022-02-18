require 'rails_helper'

RSpec.describe Fruits::ReviewsController, type: :controller do
  describe 'GET #show' do
    it 'returns expected review', :lobanov do
      get(:show, params: {fruit_id: '1', id: '1'})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({text: 'review #1', positive: true})
    end
  end

  describe 'GET #index' do
    it 'returns expected collection', :lobanov do
      get(:index, params: {fruit_id: '1'})

      expect(response).to have_http_status(:ok)
      expect(json_body.size).to eq(4)
    end
  end

  describe 'POST #create' do
    it 'returns 201 status', :lobanov do
      post(:create, params: {fruit_id: '1', text: 'hello', positive: true}, as: :json)

      expect(response).to have_http_status(:created)
      expect(json_body).to eq({})
    end
  end

  describe 'GET #stats' do
    it 'returns 200 status', :lobanov do
      get(:stats, params: {fruit_id: 1})

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({avg: 5.0})
    end
  end
end