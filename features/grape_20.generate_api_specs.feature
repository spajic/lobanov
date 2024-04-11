@grape_2.0
Feature: generate complete specs for API
  When you write lobanov specs for REST JSON API

  Scenario: basic usage
    When I cd to "../../test_apps/grape_2.0"

    Given a directory "frontend" does not exist

    Given a file named "frontend/api-backend-specification/private/v2/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: Test todo API for Lobanov development
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
      paths: {}
      """

    Given a file named "frontend/api-backend-specification/private/v2/components/responses/TodosShow200Response.yaml" with:
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
          "$ref": "../components/schemas/Todo.yaml"
        description:
          type: string
          example: Have a rest
        created_at:
          type: integer
          example: 1712782800
      """

    Given a file named "spec/requests/fruits_controller_spec.rb" with:
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

        describe '#index' do
          it 'returns expected resources', :lobanov do
            get('/api/v2/todos?q=to', {title: 'Todo'})

            expect(last_response.status).to eq(200)
            expect(parsed_body).to eq(API::V2::PLANS)
          end
        end

        describe '#show' do
          it 'returns expected resources', :lobanov do
            get('/api/v2/todos/3')

            expect(last_response.status).to eq(200)
            expect(parsed_body).to eq(API::V2::PLANS.last)
          end
        end

        describe '#update' do
          it 'returns expected resources', :lobanov do
            put('/api/v2/todos/3', {title: 'Test'})

            expect(last_response.status).to eq(200)
            expect(parsed_body).to eq(API::V2::PLANS.last)
          end
        end

        describe 'P#create' do
          it 'returns expected resources', :lobanov do
            post('/api/v2/todos', {title: 'Test'})

            expect(last_response.status).to eq(201)
            expect(parsed_body).to eq(API::V2::PLANS.last)
          end
        end

        describe '#delete' do
          it 'returns expected resources', :lobanov do
            delete('/api/v2/todos/3')

            expect(last_response.status).to eq(200)
            expect(parsed_body).to eq({success: true})
          end
        end
      end
      """

    Given a file named "frontend/api-backend-specification/private/v2/components/schemas/Todo.yaml" with:
    """yaml
    ---
    type: string
    example: 'Todo #3'
    """

    When I run `rspec spec/requests`

    Then the examples should all pass

    Then a yaml named "frontend/api-backend-specification/private/v2/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    info:
      title: Test todo API for Lobanov development
      description: API which is used to develop Lobanov gem.
      version: 0.0.1
    paths:
      "/api/v2/todos":
        get:
          description: GET /todos
          operationId: TodosList
          responses:
            '200':
              description: GET /todos -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosList200Response.yaml"
          tags:
          - lobanov
          - Todos
          parameters:
          - in: path
            name: q
            description: q
            schema:
              type: string
            required: true
            example: to
          - in: path
            name: title
            description: title
            schema:
              type: string
            required: true
            example: Todo
          - in: query
            name: q
            description: q
            schema:
              type: string
            required: true
            example: to
          - in: query
            name: title
            description: title
            schema:
              type: string
            required: true
            example: Todo
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
        put:
          description: PUT /todos/:id
          operationId: TodosUpdate
          responses:
            '200':
              description: PUT /todos/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosUpdate200Response.yaml"
          tags:
          - lobanov
          - Todos
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "./components/requestBodies/TodosUpdateRequestBody.yaml"
        delete:
          description: DELETE /todos/:id
          operationId: TodosDelete
          responses:
            '200':
              description: DELETE /todos/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/TodosDelete200Response.yaml"
          tags:
          - lobanov
          - Todos
      """

    # ============= RESPONSES =============

    Then a file named "frontend/api-backend-specification/private/v2/components/responses/TodosList200Response.yaml" should contain:
      """yaml
      ---
      type: array
      minItems: 1
      uniqueItems: true
      items:
        type: object
        required:
        - id
        - title
        - description
        - created_at
        properties:
          id:
            type: integer
            example: 1
          title:
            type: string
            example: 'Todo #1'
          description:
            type: string
            example: Wake up, Neo
          created_at:
            type: integer
            example: 1712782800
      """

    Then a file named "frontend/api-backend-specification/private/v2/components/responses/TodosShow200Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v2/components/responses/TodosCreate201Response.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/private/v2/components/responses/TodosDelete200Response.yaml" should contain:
      """yaml
      ---
      type: object
      required:
      - success
      properties:
        success:
          type: boolean
          example: true
      """

    Then a file named "frontend/api-backend-specification/private/v2/components/responses/TodosUpdate200Response.yaml" should contain:
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

    # ============= REQUEST BODIES =============

    Then a yaml named "frontend/api-backend-specification/private/v2/components/requestBodies/TodosCreateRequestBody.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v2/components/requestBodies/TodosUpdateRequestBody.yaml" should contain:
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
