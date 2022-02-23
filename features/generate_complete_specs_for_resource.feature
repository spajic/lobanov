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
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/components/schemas"

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
          let(:apple) { {id: '1', name: 'apple', color: 'green', weight: 150, seasonal: false} }
          it 'returns expected response with 200 and empty body', :lobanov do
            put(:update, params: apple, as: :json)

            expect(response).to have_http_status(:ok)
          end
        end

        describe 'DELETE #destroy' do
          it 'returns expected response with 200 and empty body', :lobanov do
            delete(:destroy, params: {id: '1'})

            expect(response).to have_http_status(:ok)
          end
        end

        describe '404 on resource show' do
          it 'returns 404 for non-existing fruit', :lobanov do
            get(:show, params: {id: '999'})

            expect(response).to have_http_status(404)
          end
        end

        describe '401 on resource show' do
          it 'returns 401 for non-authorized fruit', :lobanov do
            get(:show, params: {id: '666'})

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
            post(:upvote, params: {id: '5'})

            expect(response).to have_http_status(201)
          end
        end
      end
      """

    Given a file named "spec/controllers/fruits/reviews_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe Fruits::ReviewsController, type: :controller do
        describe 'GET #show' do
          it 'returns expected review', :lobanov do
            get(:show, params: {fruit_id: '1', id: '1'})

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({text: 'review #1', positive: true})
          end
        end

        describe 'GET #index' do
          it 'returns expected collection', :lobanov do
            get(:index, params: {fruit_id: '1'})

            expect(response).to have_http_status(:ok)
            expect(json_body.size).to eq(4)
          end
        end

        describe 'POST #create' do
          it 'returns 201 status', :lobanov do
            post(:create, params: {fruit_id: '1', text: 'hello', positive: true}, as: :json)

            expect(response).to have_http_status(:created)
            expect(json_body).to eq({})
          end
        end

        describe 'GET #stats' do
          it 'returns 200 status', :lobanov do
            get(:stats, params: {fruit_id: 1})

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({avg: 5.0})
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
      "/fruits/{fruit_id}/reviews/{id}":
        get:
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsReviewsShow200Response"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '1'
      "/fruits/{fruit_id}/reviews":
        get:
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsReviewsIndex200Response"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
        post:
          responses:
            '201':
              description: POST /fruits/:fruit_id/reviews -> 201
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsReviewsCreate201Response"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "#/components/requestBodies/FruitsReviewsCreateRequestBody"
      "/fruits/{fruit_id}/reviews/stats":
        get:
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews/stats -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsReviewsStats200Response"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
      "/fruits":
        get:
          responses:
            '200':
              description: GET /fruits -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsIndex200Response"
        post:
          responses:
            '201':
              description: POST /fruits -> 201
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsCreate201Response"
            '400':
              description: POST /fruits -> 400
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsCreate400Response"
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "#/components/requestBodies/FruitsCreateRequestBody"
      "/fruits/{id}":
        put:
          responses:
            '200':
              description: PUT /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsUpdate200Response"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '1'
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "#/components/requestBodies/FruitsUpdateRequestBody"
        delete:
          responses:
            '200':
              description: DELETE /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsDestroy200Response"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '1'
        get:
          responses:
            '404':
              description: GET /fruits/:id -> 404
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsShow404Response"
            '401':
              description: GET /fruits/:id -> 401
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsShow401Response"
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsShow200Response"
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
      "/fruits/{id}/upvote":
        post:
          responses:
            '201':
              description: POST /fruits/:id/upvote -> 201
              content:
                application/json:
                  schema:
                    "$ref": "#/components/responses/FruitsUpvote201Response"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '5'
    components:
      schemas: {}
      requestBodies:
        FruitsUpdateRequestBody:
          "$ref": "./components/requestBodies/FruitsUpdateRequestBody.yaml"
        FruitsCreateRequestBody:
          "$ref": "./components/requestBodies/FruitsCreateRequestBody.yaml"
        FruitsReviewsCreateRequestBody:
          "$ref": "./components/requestBodies/FruitsReviewsCreateRequestBody.yaml"
      responses:
        FruitsReviewsShow200Response:
          "$ref": "./components/responses/FruitsReviewsShow200Response.yaml"
        FruitsReviewsIndex200Response:
          "$ref": "./components/responses/FruitsReviewsIndex200Response.yaml"
        FruitsReviewsCreate201Response:
          "$ref": "./components/responses/FruitsReviewsCreate201Response.yaml"
        FruitsReviewsStats200Response:
          "$ref": "./components/responses/FruitsReviewsStats200Response.yaml"
        FruitsIndex200Response:
          "$ref": "./components/responses/FruitsIndex200Response.yaml"
        FruitsCreate201Response:
          "$ref": "./components/responses/FruitsCreate201Response.yaml"
        FruitsUpdate200Response:
          "$ref": "./components/responses/FruitsUpdate200Response.yaml"
        FruitsDestroy200Response:
          "$ref": "./components/responses/FruitsDestroy200Response.yaml"
        FruitsShow404Response:
          "$ref": "./components/responses/FruitsShow404Response.yaml"
        FruitsShow401Response:
          "$ref": "./components/responses/FruitsShow401Response.yaml"
        FruitsCreate400Response:
          "$ref": "./components/responses/FruitsCreate400Response.yaml"
        FruitsUpvote201Response:
          "$ref": "./components/responses/FruitsUpvote201Response.yaml"
        FruitsShow200Response:
          "$ref": "./components/responses/FruitsShow200Response.yaml"
    """

    # ============= RESPONSES =============

    Then a file named "frontend/api-backend-specification/components/responses/FruitsIndex200Response.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/components/responses/FruitsShow200Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/components/responses/FruitsCreate400Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/components/responses/FruitsShow401Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/components/responses/FruitsShow404Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a file named "frontend/api-backend-specification/components/responses/FruitsReviewsShow200Response.yaml" should contain:
      """yaml
      ---
      type: object
      required:
      - text
      - positive
      properties:
        text:
          type: string
          example: 'review #1'
        positive:
          type: boolean
          example: true
      """

    Then a file named "frontend/api-backend-specification/components/responses/FruitsReviewsIndex200Response.yaml" should contain:
      """yaml
      ---
      type: array
      minItems: 1
      uniqueItems: true
      items:
        type: object
        required:
        - text
        properties:
          text:
            type: string
            example: 'review #1'
          positive:
            type: boolean
            example: true
      """

    Then a file named "frontend/api-backend-specification/components/responses/FruitsReviewsStats200Response.yaml" should contain:
      """yaml
      ---
      type: object
      required:
      - avg
      properties:
        avg:
          type: number
          example: 5.0
      """

    # ============= REQUEST BODIES =============

    Then a yaml named "frontend/api-backend-specification/components/requestBodies/FruitsUpdateRequestBody.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/components/requestBodies/FruitsCreateRequestBody.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/components/requestBodies/FruitsUpvoteRequestBody.yaml" should not exist

    Then a file named "frontend/api-backend-specification/components/requestBodies/FruitsReviewsCreateRequestBody.yaml" should contain:
      """yaml
      ---
      type: object
      required:
      - text
      - positive
      properties:
        text:
          type: string
          example: hello
        positive:
          type: boolean
          example: true
      """
