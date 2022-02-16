Feature: generate complete specs for resource
  When you write lobanov specs for /resources CRUD + errors

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
      paths: {}
      components:
        schemas: {}
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/paths"

    Given a file named "spec/requests/fruits_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe FruitsController, type: :request do
        describe 'GET #show' do
          it 'returns expected resource', :lobanov do
            get('/wapi/fruits/2?q=true')

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({name: 'lemon', color: 'yellow', weight: 50, seasonal: false})
          end
        end
      end
      """

    Given a file named "spec/controllers/fruits_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe FruitsController, type: :controller do
        describe 'GET #index' do
          it 'returns expected collection', :lobanov do
            get(:index)

            expect(response).to have_http_status(:ok)
            expect(json_body[:items].size).to eq(4)
          end
        end

        describe 'POST #create' do
          let(:apple) { {name: 'apple', color: 'green', weight: 150, seasonal: false} }
          it 'returns expected response with 201', :lobanov do
            post(:create, params: apple, as: :json)

            expect(response).to have_http_status(:created)
          end
        end

        describe 'PUT #update' do
          let(:apple) { {id: 1, name: 'apple', color: 'green', weight: 150, seasonal: false} }
          it 'returns expected response with 200 and empty body', :lobanov do
            put(:update, params: apple, as: :json)

            expect(response).to have_http_status(:ok)
          end
        end

        describe 'DELETE #destroy' do
          it 'returns expected response with 200 and empty body', :lobanov do
            delete(:destroy, params: {id: 1})

            expect(response).to have_http_status(:ok)
          end
        end

        describe '404 on resource show' do
          it 'returns 404 for non-existing fruit', :lobanov do
            get(:show, params: {id: 999})

            expect(response).to have_http_status(404)
          end
        end

        describe '401 on resource show' do
          it 'returns 401 for non-authorized fruit', :lobanov do
            get(:show, params: {id: 666})

            expect(response).to have_http_status(401)
          end
        end

        describe '400 on POST new fruit' do
          it 'returns 400 for incorrect params', :lobanov do
            post(:create, params: {color: 'green'}, as: :json)

            expect(response).to have_http_status(400)
          end
        end

        describe '201 on POST fruits/:id/upvote' do
          it 'returns 201', :lobanov do
            post(:upvote, params: {id: 5})

            expect(response).to have_http_status(201)
          end
        end
      end
      """

    When I run `rspec`

    Then the examples should all pass

    Then a yaml named "frontend/api-backend-specification/index.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    info:
      title: Test fruits API for Lobanov development
      description: API which is used to develop Lobanov gem.
      version: 0.0.1
    paths:
      "/fruits":
        "$ref": "./paths/fruits/path.yaml"
      "/fruits/{id}":
        "$ref": "./paths/fruits/[id]/path.yaml"
      "/fruits/{id}/upvote":
        "$ref": "./paths/fruits/[id]/upvote/path.yaml"
    components:
      schemas:
        FruitsIndex200Response:
          "$ref": "./components/FruitsIndex200Response.yaml"
        FruitsShow200Response:
          "$ref": "./components/FruitsShow200Response.yaml"
        FruitsCreate201Response:
          "$ref": "./components/FruitsCreate201Response.yaml"
        FruitsUpdate200Response:
          "$ref": "./components/FruitsUpdate200Response.yaml"
        FruitsDestroy200Response:
          "$ref": "./components/FruitsDestroy200Response.yaml"
        FruitsShow404Response:
          "$ref": "./components/FruitsShow404Response.yaml"
        FruitsShow401Response:
          "$ref": "./components/FruitsShow401Response.yaml"
        FruitsCreate400Response:
          "$ref": "./components/FruitsCreate400Response.yaml"
        FruitsUpvote201Response:
          "$ref": "./components/FruitsUpvote201Response.yaml"
        FruitsUpdateRequestBody:
          "$ref": "./components/FruitsUpdateRequestBody.yaml"
        FruitsCreateRequestBody:
          "$ref": "./components/FruitsCreateRequestBody.yaml"
    """

    # ============= PATHS =============

    Then a yaml named "frontend/api-backend-specification/paths/fruits/path.yaml" should contain:
      """yaml
      ---
      post:
        requestBody:
          required: true
          content:
            application/json:
              schema:
                "$ref": "../../components/FruitsCreateRequestBody.yaml"
        responses:
          '201':
            description: POST /fruits -> 201
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsCreate201Response.yaml"
          '400':
            description: POST /fruits -> 400
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsCreate400Response.yaml"
      get:
        responses:
          '200':
            description: GET /fruits -> 200
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsIndex200Response.yaml"
      """

      Then a yaml named "frontend/api-backend-specification/paths/fruits/[id]/path.yaml" should contain:
        """yaml
        ---
        put:
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: integer
            required: true
            example: '1'
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "../../../components/FruitsUpdateRequestBody.yaml"
          responses:
            '200':
              description: PUT /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsUpdate200Response.yaml"
        get:
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: integer
            required: true
            example: '2'
          - in: query
            name: q
            description: q
            schema:
              type: string
            required: true
          responses:
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsShow200Response.yaml"
            '404':
              description: GET /fruits/:id -> 404
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsShow404Response.yaml"
            '401':
              description: GET /fruits/:id -> 401
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsShow401Response.yaml"
        delete:
          responses:
            '200':
              description: DELETE /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsDestroy200Response.yaml"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: integer
            required: true
            example: '1'
        """

      # ============= COMPONENTS =============

      Then a file named "frontend/api-backend-specification/components/FruitsIndex200Response.yaml" should contain:
        """yaml
        ---
        type: object
        required:
        - items
        properties:
          items:
            type: array
            minItems: 1
            uniqueItems: true
            items:
              type: object
              required:
              - name
              - weight
              properties:
                name:
                  type: string
                  example: orange
                color:
                  type: string
                  example: orange
                weight:
                  type: integer
                  example: 100
                seasonal:
                  type: boolean
                  example: false
        """

      Then a file named "frontend/api-backend-specification/components/FruitsShow200Response.yaml" should contain:
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

        Then a yaml named "frontend/api-backend-specification/components/FruitsCreate400Response.yaml" should contain:
          """yaml
          ---
          type: object
          required:
          - message
          - title
          properties:
            message:
              type: string
              example: |-
                param is missing or the value is empty: name
                Did you mean?  action
                               format
                               controller
                               color
            title:
              type: string
              example: Bad request
          """

          Then a yaml named "frontend/api-backend-specification/components/FruitsShow401Response.yaml" should contain:
            """yaml
            ---
            type: object
            properties: {}
            """

          Then a yaml named "frontend/api-backend-specification/components/FruitsShow404Response.yaml" should contain:
            """yaml
            ---
            type: object
            properties: {}
            """

          Then a yaml named "frontend/api-backend-specification/components/FruitsUpdateRequestBody.yaml" should contain:
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

            Then a yaml named "frontend/api-backend-specification/components/FruitsCreateRequestBody.yaml" should contain:
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

              Then a file named "frontend/api-backend-specification/components/FruitsUpvoteRequestBody.yaml" should not exist
