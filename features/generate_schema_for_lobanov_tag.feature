Feature: generate schema for test with :lobanov tag
  When you write rspec test with :lobanov tag it generates schema

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a file named "spec/controllers/fruits_controller_spec.rb" with:
      """ruby
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
        "/fruits":
          "$ref": "./paths/fruits.yaml"
      components:
        schemas:
          FruitsIndexResponse:
            "$ref": "./components/FruitsIndexResponse.yaml"
      """

    Then a file named "frontend/api-backend-specification/components/fruits/Fruits.yaml" should contain:
      """yaml
      ---
      type: object
      required:
      - fruits
      properties:
        fruits:
          type: string
          example: will_be_here
      """

      Then a file named "frontend/api-backend-specification/paths/fruits.yaml" should contain:
      """yaml
      ---
      get:
        responses:
          '200':
            description: GET /fruits -> 200
            content:
              application/json:
                schema:
                  "$ref": "../components/FruitsIndexResponse.yaml"
      """

