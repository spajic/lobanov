@grape_2.0
Feature: prevent unexpected schema changes
  When you write lobanov specs for REST JSON API

  Scenario: basic usage for wapi
    When I cd to "../../test_apps/grape_2.0"

    Given a file named "lobanov_initializer.rb" with:
      """rb
      Lobanov.configure do |config|
        config.specification_folder = 'frontend/api-backend-specification'
        config.namespaces = { 'api/v2' => 'wapi' }
      end
      """
      
    Given a file named "frontend/api-backend-specification/wapi/index.yaml" with:
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
          - Todos
    """

    Given a file named "frontend/api-backend-specification/wapi/components/responses/TodosShow200Response.yaml" with:
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
    """

    Given a file named "frontend/api-backend-specification/wapi/components/schemas/Todo.yaml" with:
    """yaml
    ---
    type: integer
    example: 1
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

    When I run `rspec spec/requests/todo_api_spec.rb`

    Then the examples should all fail

    Then the output should contain failures:
    """
    Lobanov::SchemaMismatchError
      LOBANOV DETECTED SCHEMA MISMATCH!

      Interaction: 'GET /todos/:id'
      Response file: frontend/api-backend-specification/wapi/components/responses/TodosShow200Response.yaml

      Schema diff:
      ---
      type: object
      properties:
        id:
          type: integer
        title:
     -    type: integer
     +    type: string
        created_at:
          type: integer
    """
