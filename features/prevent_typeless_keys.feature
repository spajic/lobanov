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
      paths:
        "/wapi/fruits/{id}":
          get:
            description: GET /fruits/:id
            operationId: FruitsShow
            responses:
              '200':
                description: GET /fruits/:id -> 200
                content:
                  application/json:
                    schema:
                      "$ref": "./components/responses/FruitsShow200Response.yaml"
            tags:
            - lobanov
            parameters:
            - in: path
              name: id
              description: id
              schema:
                type: string
              required: true
              example: '2'
            - in: query
              name: q
              description: q
              schema:
                type: string
              required: true
              example: with_null_name
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/components/schemas"

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
        nullable: true
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
    Lobanov::MissingTypeOrExampleError:
      {:missing_types=>["properties->name"], :missing_examples=>["properties->name"]}
    """
