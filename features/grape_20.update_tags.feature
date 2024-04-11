@grape_2.0
Feature: UPDATE_TAGS in existing schema
  Scenario: you have openapi-schema and you want to update tags in it
    # Note that schema is incorrect, but this is not validated
    When I cd to "../../test_apps/grape_2.0"

    Given a file named "lobanov_initializer.rb" with:
      """rb
      Lobanov.configure do |config|
        config.specification_folder = 'frontend/api-backend-specification'
        config.namespaces = { 'api/v2' => 'api/v2' }
      end
      """

    Given a directory "frontend" does not exist

    Given a file named "frontend/api-backend-specification/api/v2/index.yaml" with:
    """yaml
    ---
    openapi: 3.0.1
    paths:
      "/api/v2/todos/{id}":
        get:
          description: GET /todos/:id
          operationId: TodosShow
          responses:
            '200':
              description: GET /todos/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosShow200Response.yaml"
          tags:
          - lobanov
          - MyCustomTag
    """

    Given a file named "frontend/api-backend-specification/api/v2/components/responses/TodosShow200Response.yaml" with:
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
        "$ref": "../schemas/Todo.yaml"
      description:
        type: string
        example: Have a rest
      created_at:
        type: integer
        example: 1712782800
      some:
        example: FFFFUUUUUU, THIS SCHEMA IS BROKEN! 
    """

    Given a file named "frontend/api-backend-specification/api/v2/components/schemas/Todo.yaml" with:
    """yaml
    ---
    type: string
    example: lemon
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

      describe '#show' do
        it 'returns expected resources', :lobanov do
          get('/api/v2/todos/3')

          expect(last_response.status).to eq(200)
          expect(parsed_body).to eq(API::V2::PLANS.last)
        end
      end
    end
    """

    Given I append "true" to the environment variable "UPDATE_TAGS"

    When I run `rspec spec/requests/todo_api_spec.rb`

    Then the examples should all pass

    Then a yaml named "frontend/api-backend-specification/api/v2/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    paths:
      "/api/v2/todos/{id}":
        get:
          description: GET /todos/:id
          operationId: TodosShow
          responses:
            '200':
              description: GET /todos/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosShow200Response.yaml"
          tags:
          - lobanov
          - MyCustomTag
          - Todos
    """

