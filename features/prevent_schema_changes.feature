Feature: prevent unexpected schema changes
  When you write lobanov specs for REST JSON API

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a file named "frontend/api-backend-specification/index.yaml" with:
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
          - in: query
            name: q
            description: q
            schema:
              type: string
            required: true
            example: 'true'
          responses:
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow200Response.yaml"
    """

    Given a file named "frontend/api-backend-specification/components/responses/FruitsShow200Response.yaml" with:
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
        "$ref": "./components/schemas/FruitName.yaml"
      color:
        type: string
        example: yellow
      weight:
        type: integer
        example: 50
      seasonal:
        type: boolean
        example: false
    """

    Given a file named "frontend/api-backend-specification/components/schemas/FruitName.yaml" with:
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
          get('/wapi/fruits/2?q=with_integer_name')

          expect(response).to have_http_status(:ok)
          expect(json_body).to eq({color: 'yellow', weight: 50, seasonal: false})
        end
      end
    end
    """

    When I run `rspec spec/requests/fruits_controller_spec.rb`

    Then the examples should all fail

    Then the output should contain failures:
    """
    Lobanov::SchemaMismatchError
      LOBANOV DETECTED SCHEMA MISMATCH!

      Interaction 'GET /fruits/:id' failed! Schema changed:
      ---
      type: object
      properties:
        name:
      -    type: string
      +    type: integer
        color:
          type: string
        weight:
          type: integer
        seasonal:
      type: boolean
    """
