# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FruitsController, type: :request do
  describe 'GET #show' do
    it 'returns expected resource', :lobanov do
      get('/wapi/fruits/2?q=with_integer_name')

      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({ color: 'yellow', weight: 50, name: 999, seasonal: false })
    end
  end
end
