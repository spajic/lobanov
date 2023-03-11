Feature: UPDATE_TAGS in existing schema
  Scenario: you have openapi-schema and you want to update tags in it
    # Note that schema is incorrect, but this is not validated
    When I cd to "../../test_apps/rails_61"

    Given a file named "config/initializers/lobanov_initializer.rb" with:
      """rb
      Lobanov.configure do |config|
        config.specification_folder = 'frontend/api-backend-specification'
      end
      """

    Given a directory "frontend" does not exist

    Given a file named "frontend/api-backend-specification/wapi/index.yaml" with:
    """yaml
    ---
    openapi: 3.0.1
    paths:
      "/wapi/fruits/{id}":
        get:
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: 'string'
            required: true
            example: '2'
          responses:
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow200Response.yaml"
          tags:
          - lobanov
          - MyCustomTag
    """

    Given a file named "frontend/api-backend-specification/wapi/components/responses/FruitsShow200Response.yaml" with:
    """yaml
    ---
    type: object
    required:
    - name
    - color
    - weight
    - seasonal
    properties:
      name:
        "$ref": "../schemas/FruitName.yaml"
      color:
        type: string
        example: yellow
      weight:
        type: integer
        example: 50
      seasonal:
        type: boolean
        example: false
      some:
        example: FFFFUUUUUU, THIS SCHEMA IS BROKEN! 
    """

    Given a file named "frontend/api-backend-specification/wapi/components/schemas/FruitName.yaml" with:
    """yaml
    ---
    type: string
    example: lemon
    """

    Given a file named "spec/requests/fruits_controller_spec.rb" with:
    """ruby
    require 'rails_helper'

    RSpec.describe FruitsController, type: :request do
      describe 'GET #show' do
        it 'returns expected resource', :lobanov do
          get('/wapi/fruits/2')

          expect(response).to have_http_status(:ok)
          expect(json_body).to eq({color: 'yellow', name: 'lemon', seasonal: false, weight: 50})
        end
      end
    end
    """

    Given I append "true" to the environment variable "UPDATE_TAGS"

    When I run `rspec spec/requests/fruits_controller_spec.rb`

    Then the examples should all pass

    # Check that the new tag `Fruits` is added and old custom tag is preserved
    Then a yaml named "frontend/api-backend-specification/wapi/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    paths:
      "/wapi/fruits/{id}":
        get:
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: 'string'
            required: true
            example: '2'
          responses:
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow200Response.yaml"
          tags:
          - lobanov
          - MyCustomTag
          - Fruits
    """

