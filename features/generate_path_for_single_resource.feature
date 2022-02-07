Feature: generate path for single resource
  When you write lobanov spec for /resources/:id path

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a file named "spec/controllers/fruits_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe FruitsController, type: :controller do
        describe 'GET #show' do
          it 'returns expected resource', :lobanov do
            get(:show, params: {id: 1})

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({color: nil})
          end
        end
      end
      """

    Given a file named "frontend/api-backend-specification/index.yaml" with:
      """yaml
      ---
      paths: {}
      components:
        schemas: {}
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/paths"

    When I run `rspec spec/controllers/fruits_controller_spec.rb`

    Then the example should pass

    Then a file named "frontend/api-backend-specification/index.yaml" should contain:
    """yaml
    ---
    paths:
      "/fruits/[id]":
        "$ref": "./paths/fruits/[id].yaml"
    """

    Then a file named "frontend/api-backend-specification/paths/fruits/[id].yaml" should contain:
      """yaml
      ---
      get:
        parameters:
        - in: path
          name: id
          description: id
          schema:
            type: integer
          required: true
          example: '1'
        responses:
          '200':
            description: GET /fruits/:id -> 200
            content:
              application/json:
                schema:
                  "$ref": "../../components//Fruit.yaml"

      """
