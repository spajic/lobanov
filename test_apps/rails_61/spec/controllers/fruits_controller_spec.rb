# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FruitsController, type: :controller do
  describe 'index' do
    subject { get :index, params: { }, format: :json }

    # with Lobanov.capture block syntax
    it 'returns expected json', :aggregate_failures do
      Lobanov.capture do
        subject
      end
      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({fruits: 'will_be_here'})
    end

    # with :lobanov rspec-tag syntax
    it 'returns expected json', :aggregate_failures, :lobanov do
      subject
      expect(response).to have_http_status(:ok)
      expect(json_body).to eq({fruits: 'will_be_here'})
    end
  end
end
