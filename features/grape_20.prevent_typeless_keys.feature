@grape_2.0
Feature: prevent typeless examples
  When you write lobanov specs for REST JSON API

  Scenario: basic usage todos api
    When I cd to "../../test_apps/grape_2.0"
     
    Given a directory "frontend" does not exist

    Given a file named "frontend/api-backend-specification/wapi/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: Test todo API for Lobanov development
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
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
    - description
    - created_at
    properties:
      id:
        type: integer
        example: 3
      title:
        nullable: true
      description:
        type: string
        example: Have a rest
      created_at:
        type: integer
        example: 1712782800
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
    Lobanov::MissingTypeOrExampleError:
      Problem with TodosShow

      Missing types:
      properties->title

      Missing examples:
      properties->title
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
        type: string
        example: 'Todo #3'
      description:
        type: string
        example: Have a rest
      created_at:
        type: integer
        example: 1712782800
    """
