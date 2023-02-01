Feature: prevent typeless examples
  When you write lobanov specs for REST JSON API

  Scenario: basic usage fruits controller
    When I cd to "../../test_apps/rails_61"

    Given a file named "frontend/api-backend-specification/wapi/index.yaml" with:
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

    Given an empty directory "frontend/api-backend-specification/wapi/components"

    Given an empty directory "frontend/api-backend-specification/wapi/components/schemas"

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
      Problem with FruitsShow

      Missing types:
      properties->name

      Missing examples:
      properties->name
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
        type: string
        example: lemon
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

  Scenario: basic usage vegetables controller
    When I cd to "../../test_apps/rails_61"

    Given a file named "frontend/api-backend-specification/private/v6/index.yaml" with:
      """yaml
      ---
      paths:
        "/api/v6/vegetables/{id}":
          get:
            description: GET /vegetables/:id
            operationId: VegetablesShow
            responses:
              '404':
                description: GET /vegetables/:id -> 404
                content:
                  application/json:
                    schema:
                      "$ref": "./components/responses/VegetablesShow404Response.yaml"
              '401':
                description: GET /vegetables/:id -> 401
                content:
                  application/json:
                    schema:
                      "$ref": "./components/responses/VegetablesShow401Response.yaml"
              '200':
                description: GET /vegetables/:id -> 200
                content:
                  application/json:
                    schema:
                      "$ref": "./components/responses/VegetablesShow200Response.yaml"
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
              example: with_integer_name
      """

    Given an empty directory "frontend/api-backend-specification/private/v6/components"

    Given an empty directory "frontend/api-backend-specification/private/v6/components/schemas"

    Given a file named "frontend/api-backend-specification/private/v6/components/responses/VegetablesShow200Response.yaml" with:
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

    Given a file named "spec/requests/vegetables_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe Api::V6::VegetablesController, type: :request do
        describe 'GET #show' do
          it 'returns expected resource', :lobanov do
            get('/api/v6/vegetables/2?q=with_null_name')

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({ color: 'yellow', name: nil, weight: 50, seasonal: false })
          end
        end
      end
      """

    When I run `rspec spec/requests/vegetables_controller_spec.rb`

    Then the examples should all fail

    Then the output should contain failures:
    """
    Lobanov::MissingTypeOrExampleError:
      Problem with VegetablesShow

      Missing types:
      properties->name

      Missing examples:
      properties->name
    """

    Given a file named "frontend/api-backend-specification/private/v6/components/responses/VegetablesShow200Response.yaml" with:
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
          type: string
          example: potato
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
