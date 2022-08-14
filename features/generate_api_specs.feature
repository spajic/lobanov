Feature: generate complete specs for API
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
      paths: {}
      """

    Given a file named "frontend/api-backend-specification/openapi_single.yaml" does not exist

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
      "/wapi/fruits/{fruit_id}/reviews/{id}":
        get:
          description: GET /fruits/:fruit_id/reviews/:id
          operationId: FruitsReviewsShow
          tags:
          - lobanov
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsReviewsShow200Response.yaml"
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
      "/wapi/fruits/{fruit_id}/reviews":
        get:
          description: GET /fruits/:fruit_id/reviews
          operationId: FruitsReviewsIndex
          tags:
          - lobanov
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsReviewsIndex200Response.yaml"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
        post:
          description: POST /fruits/:fruit_id/reviews
          operationId: FruitsReviewsCreate
          tags:
          - lobanov
          responses:
            '201':
              description: POST /fruits/:fruit_id/reviews -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsReviewsCreate201Response.yaml"
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
                  "$ref": "./components/requestBodies/FruitsReviewsCreateRequestBody.yaml"
      "/wapi/fruits/{fruit_id}/reviews/stats":
        get:
          description: GET /fruits/:fruit_id/reviews/stats
          operationId: FruitsReviewsStats
          tags:
          - lobanov
          responses:
            '200':
              description: GET /fruits/:fruit_id/reviews/stats -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsReviewsStats200Response.yaml"
          parameters:
          - in: path
            name: fruit_id
            description: fruit_id
            schema:
              type: string
            required: true
            example: '1'
      "/wapi/fruits":
        get:
          description: GET /fruits
          operationId: FruitsIndex
          tags:
          - lobanov
          responses:
            '200':
              description: GET /fruits -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsIndex200Response.yaml"
        post:
          description: POST /fruits
          operationId: FruitsCreate
          tags:
          - lobanov
          responses:
            '201':
              description: POST /fruits -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsCreate201Response.yaml"
            '400':
              description: POST /fruits -> 400
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsCreate400Response.yaml"
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "./components/requestBodies/FruitsCreateRequestBody.yaml"
      "/wapi/fruits/{id}":
        put:
          description: PUT /fruits/:id
          operationId: FruitsUpdate
          tags:
          - lobanov
          responses:
            '200':
              description: PUT /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsUpdate200Response.yaml"
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
                  "$ref": "./components/requestBodies/FruitsUpdateRequestBody.yaml"
        delete:
          description: DELETE /fruits/:id
          operationId: FruitsDestroy
          tags:
          - lobanov
          responses:
            '200':
              description: DELETE /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsDestroy200Response.yaml"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '1'
        get:
          description: GET /fruits/:id
          operationId: FruitsShow
          tags:
          - lobanov
          responses:
            '404':
              description: GET /fruits/:id -> 404
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow404Response.yaml"
            '401':
              description: GET /fruits/:id -> 401
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow401Response.yaml"
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsShow200Response.yaml"
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
      "/wapi/fruits/{id}/upvote":
        post:
          description: POST /fruits/:id/upvote
          operationId: FruitsUpvote
          tags:
          - lobanov
          responses:
            '201':
              description: POST /fruits/:id/upvote -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/FruitsUpvote201Response.yaml"
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: string
            required: true
            example: '5'
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

    Then a yaml named "frontend/api-backend-specification/openapi_single.yaml" should contain:
    """yaml
    ---
    openapi: 3.0.1
    info:
      title: Test fruits API for Lobanov development
      description: API which is used to develop Lobanov gem.
      version: 0.0.1
    paths:
      '/wapi/fruits/{fruit_id}/reviews/{id}':
        get:
          description: 'GET /fruits/:fruit_id/reviews/:id'
          operationId: FruitsReviewsShow
          responses:
            '200':
              description: 'GET /fruits/:fruit_id/reviews/:id -> 200'
              content:
                application/json:
                  schema:
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
          tags:
            - lobanov
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
      '/wapi/fruits/{fruit_id}/reviews':
        get:
          description: 'GET /fruits/:fruit_id/reviews'
          operationId: FruitsReviewsIndex
          responses:
            '200':
              description: 'GET /fruits/:fruit_id/reviews -> 200'
              content:
                application/json:
                  schema:
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
          tags:
            - lobanov
          parameters:
            - in: path
              name: fruit_id
              description: fruit_id
              schema:
                type: string
              required: true
              example: '1'
        post:
          description: 'POST /fruits/:fruit_id/reviews'
          operationId: FruitsReviewsCreate
          responses:
            '201':
              description: 'POST /fruits/:fruit_id/reviews -> 201'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
          tags:
            - lobanov
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
      '/wapi/fruits/{fruit_id}/reviews/stats':
        get:
          description: 'GET /fruits/:fruit_id/reviews/stats'
          operationId: FruitsReviewsStats
          responses:
            '200':
              description: 'GET /fruits/:fruit_id/reviews/stats -> 200'
              content:
                application/json:
                  schema:
                    type: object
                    required:
                      - avg
                    properties:
                      avg:
                        type: number
                        example: 5
          tags:
            - lobanov
          parameters:
            - in: path
              name: fruit_id
              description: fruit_id
              schema:
                type: string
              required: true
              example: '1'
      /wapi/fruits:
        get:
          description: GET /fruits
          operationId: FruitsIndex
          responses:
            '200':
              description: GET /fruits -> 200
              content:
                application/json:
                  schema:
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
          tags:
            - lobanov
        post:
          description: POST /fruits
          operationId: FruitsCreate
          responses:
            '201':
              description: POST /fruits -> 201
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
            '400':
              description: POST /fruits -> 400
              content:
                application/json:
                  schema:
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
          tags:
            - lobanov
          requestBody:
            required: true
            content:
              application/json:
                schema:
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
      '/wapi/fruits/{id}':
        put:
          description: 'PUT /fruits/:id'
          operationId: FruitsUpdate
          responses:
            '200':
              description: 'PUT /fruits/:id -> 200'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
          tags:
            - lobanov
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
        delete:
          description: 'DELETE /fruits/:id'
          operationId: FruitsDestroy
          responses:
            '200':
              description: 'DELETE /fruits/:id -> 200'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
          tags:
            - lobanov
          parameters:
            - in: path
              name: id
              description: id
              schema:
                type: string
              required: true
              example: '1'
        get:
          description: 'GET /fruits/:id'
          operationId: FruitsShow
          responses:
            '200':
              description: 'GET /fruits/:id -> 200'
              content:
                application/json:
                  schema:
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
            '401':
              description: 'GET /fruits/:id -> 401'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
            '404':
              description: 'GET /fruits/:id -> 404'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
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
              example: 'true'
      '/wapi/fruits/{id}/upvote':
        post:
          description: 'POST /fruits/:id/upvote'
          operationId: FruitsUpvote
          responses:
            '201':
              description: 'POST /fruits/:id/upvote -> 201'
              content:
                application/json:
                  schema:
                    type: object
                    properties: {}
          tags:
            - lobanov
          parameters:
            - in: path
              name: id
              description: id
              schema:
                type: string
              required: true
              example: '5'
    """
