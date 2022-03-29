Feature: prevent typeless examples
  When you write lobanov specs for REST JSON API

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a file named "frontend/api-backend-specification/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: Test fruits API for Lobanov development
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
      paths: {}
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/components/schemas"

    Given a file named "spec/requests/fruits_controller_spec.rb" with:
    """ruby
    require 'rails_helper'

    RSpec.describe FruitsController, type: :request do
      describe 'GET #show' do
        it 'returns expected resource', :lobanov do
          get('/wapi/fruits/2?q=with_null_name')

          expect(response).to have_http_status(:ok)
          expect(json_body).to eq({color: 'yellow', name: nil, weight: 50, seasonal: false})
        end
      end
    end
    """

    When I run `rspec spec/requests/fruits_controller_spec.rb`

    Then the examples should all fail

    Then the output should contain failures:
    """
    Lobanov::MissingExampleError
      for "name" in {"name"=>nil, "color"=>"yellow", "weight"=>50, "seasonal"=>false}
    """
