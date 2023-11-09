Feature: Change the storage folder
  Scenario: A user has configured the storage folder via lobanov_initializer.rb
    When I cd to "../../test_apps/rails_61"

    Given a file named "config/initializers/lobanov_initializer.rb" with:
      """rb
      Lobanov.configure do |config|
        config.specification_folder = 'fffuuu'
        config.namespaces = {'wapi' => 'wapi', 'api/v6' => 'private/v6'}
      end
      """

    Given a directory "fffuuu" does not exist

    Given a file named "fffuuu/wapi/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: Test fruits API for Lobanov development
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
      paths: {}
      """

    Given a file named "./spec/requests/fruits_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe FruitsController, type: :controller do
        describe 'POST #create' do
          let(:apple) { {name: 'apple', color: 'green', weight: 150, seasonal: false} }
          it 'returns expected response with 201', :lobanov do
            post(:create, params: apple, as: :json)

            expect(response).to have_http_status(:created)
          end
        end
      end
      """

    When I run `rspec spec/requests/fruits_controller_spec.rb`

    Then the examples should all pass

    Then a yaml named "fffuuu/wapi/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    info:
      title: Test fruits API for Lobanov development
      description: API which is used to develop Lobanov gem.
      version: 0.0.1
    paths:
      "/wapi/fruits":
        post:
          description: POST /fruits
          operationId: FruitsCreate
          responses:
            '201':
              description: POST /fruits -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsCreate201Response.yaml"
          tags:
          - lobanov
          - Fruits
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "./components/requestBodies/FruitsCreateRequestBody.yaml"

    """

    Then a yaml named "fffuuu/wapi/components/requestBodies/FruitsCreateRequestBody.yaml" should contain:
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
        example: apple
      color:
        type: string
        example: green
      weight:
        type: integer
        example: 150
      seasonal:
        type: boolean
        example: false
    """

    Then a yaml named "fffuuu/wapi/components/responses/FruitsCreate201Response.yaml" should contain:
    """yaml
    ---
    type: object
    properties: {}
    """

