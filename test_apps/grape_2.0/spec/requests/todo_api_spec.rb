require 'spec_helper'
require_relative '../../lobanov_initializer'

RSpec.describe API::V2::TodoApi, type: :request do
  def app
    RackApplication.to_app
  end

  def parsed_body
    JSON.parse(last_response.body, symbolize_names: true)
  end

  describe '#show' do
    it 'returns expected resources', :lobanov do
      get('/api/v2/todos/3')

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq(API::V2::PLANS.last)
    end
  end
end