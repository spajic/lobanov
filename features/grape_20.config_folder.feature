@grape_2.0
Feature: Change the storage folder
  Scenario: A user has configured the storage folder via lobanov_initializer.rb
    When I cd to "../../test_apps/grape_2.0"

    Given a file named "lobanov_initializer.rb" with:
      """rb
      Lobanov.configure do |config|
        config.specification_folder = 'fffuuu'
        config.namespaces = {'api/v2' => 'api/v2'}
      end
      """

    Given a directory "fffuuu" does not exist

    Given a file named "fffuuu/api/v2/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: TAPI which is used to develop Lobanov gem.
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
      paths: {}
      """

    Given a file named "spec/requests/todo_api_spec.rb" with:
      """ruby
      require 'spec_helper'
      require_relative '../../lobanov_initializer'

      RSpec.describe API::V2::TodoApi, type: :request do
        def app
          RackApplication.to_app
        end

        def parsed_body
          JSON.parse(last_response.body, symbolize_names: true)
        end

        describe '#create' do
          it 'returns expected resources', :lobanov do
            post('/api/v2/todos', {title: 'Test'})

            expect(last_response.status).to eq(201)
            expect(parsed_body).to eq(API::V2::PLANS.last)
          end
        end
      end
      """

    When I successfully run `rspec spec/requests/todo_api_spec.rb`

    Then the examples should all pass

    Then a yaml named "fffuuu/api/v2/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    info:
      title: TAPI which is used to develop Lobanov gem.
      description: API which is used to develop Lobanov gem.
      version: 0.0.1
    paths:
      "/api/v2/todos":
        post:
          description: POST /todos
          operationId: TodosCreate
          responses:
            '201':
              description: POST /todos -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosCreate201Response.yaml"
          tags:
          - lobanov
          - Todos
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "./components/requestBodies/TodosCreateRequestBody.yaml"
    """

    Then a yaml named "fffuuu/api/v2/components/requestBodies/TodosCreateRequestBody.yaml" should contain:
    """yaml
    ---
    type: object
    required:
    - title
    properties:
      title:
        type: string
        example: Test
    """

    Then a yaml named "fffuuu/api/v2/components/responses/TodosCreate201Response.yaml" should contain:
    """yaml
    ---
    type: object
    required:
    - id
    - title
    - description
    - created_at
    properties:
      id:
        type: integer
        example: 3
      title:
        type: string
        example: 'Todo #3'
      description:
        type: string
        example: Have a rest
      created_at:
        type: integer
        example: 1712782800
    """

