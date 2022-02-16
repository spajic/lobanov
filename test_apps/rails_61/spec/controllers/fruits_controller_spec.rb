require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'GET #index' do
    it 'returns expected collection', :lobanov do
      get(:index)

      expect(response).to have_http_status(:ok)
      expect(json_body[:items].size).to eq(4)
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
    it 'returns expected response with 200 and empty body', :lobanov do
      put(:update, params: apple, as: :json)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns expected response with 200 and empty body', :lobanov do
      delete(:destroy, params: {id: 1})

      expect(response).to have_http_status(:ok)
    end
  end

  describe '404 on resource show' do
    it 'returns 404 for non-existing fruit', :lobanov do
      get(:show, params: {id: 999})

      expect(response).to have_http_status(404)
    end
  end

  describe '401 on resource show' do
    it 'returns 401 for non-authorized fruit', :lobanov do
      get(:show, params: {id: 666})

      expect(response).to have_http_status(401)
    end
  end

  describe '400 on POST new fruit' do
    it 'returns 400 for incorrect params', :lobanov do
      post(:create, params: {color: 'green'}, as: :json)

      expect(response).to have_http_status(400)
    end
  end

  describe '201 on POST fruits/:id/upvote' do
    it 'returns 201', :lobanov do
      post(:upvote, params: {id: 5})

      expect(response).to have_http_status(201)
    end
  end
end