require 'spec_helper'

RSpec.describe API::V2::TodoApi, type: :request do
  def app
    RackApplication.to_app
  end

  def parsed_body
    JSON.parse(last_response.body, symbolize_names: true)
  end

  describe '#index' do
    it 'returns expected resources', :lobanov do
      get('/api/v2/todos?q=to', {title: 'Todo'})

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq(API::V2::PLANS)
    end
  end

  describe '#show' do
    it 'returns expected resources', :lobanov do
      get('/api/v2/todos/3')

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq(API::V2::PLANS.last)
    end
  end

  describe '#update' do
    it 'returns expected resources', :lobanov do
      put('/api/v2/todos/3', {title: 'Test'})

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq(API::V2::PLANS.last)
    end
  end

  describe 'P#create' do
    it 'returns expected resources', :lobanov do
      post('/api/v2/todos', {title: 'Test'})

      expect(last_response.status).to eq(201)
      expect(parsed_body).to eq(API::V2::PLANS.last)
    end
  end

  describe '#delete' do
    it 'returns expected resources', :lobanov do
      delete('/api/v2/todos/3')

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq({success: true})
    end
  end
end
