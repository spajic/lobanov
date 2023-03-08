Feature: generate complete specs for API
  When you write lobanov specs for REST JSON API

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a directory "frontend" does not exist

    Given a file named "frontend/api-backend-specification/wapi/index.yaml" with:
      """yaml
      ---
      openapi: 3.0.1
      info:
        title: Test fruits API for Lobanov development
        description: API which is used to develop Lobanov gem.
        version: 0.0.1
      paths: {}
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
            get('/wapi/fruits/2?q=true')

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({name: 'lemon', color: 'yellow', weight: 50, seasonal: false})
          end
        end
      end
      """

    Given a file named "spec/requests/vegetables_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe Api::V6::VegetablesController, type: :request do
        describe 'GET #show' do
          it 'returns expected resource', :lobanov do
            get('/api/v6/vegetables/2?q=true')

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({name: 'potato', color: 'yellow', weight: 50, seasonal: false})
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

    Given a file named "spec/controllers/api/v6/vegetables_controller_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe Api::V6::VegetablesController, type: :controller do
        describe 'GET #index' do
          it 'returns expected collection', :lobanov do
            get(:index)

            expect(response).to have_http_status(:ok)
            expect(json_body[:items].size).to eq(4)
          end
        end

        describe 'POST #create' do
          let(:carrot) { { name: 'carrot', color: 'orange', weight: 150, seasonal: true } }
          it 'returns expected response with 201', :lobanov do
            post(:create, params: carrot, as: :json)

            expect(response).to have_http_status(:created)
          end
        end

        describe 'PUT #update' do
          let(:carrot) { { id: '1', name: 'carrot', color: 'orange', weight: 150, seasonal: true } }
          it 'returns expected response with 200 and empty body', :lobanov do
            put(:update, params: carrot, as: :json)

            expect(response).to have_http_status(:ok)
          end
        end

        describe 'DELETE #destroy' do
          it 'returns expected response with 200 and empty body', :lobanov do
            delete(:destroy, params: { id: '1' })

            expect(response).to have_http_status(:ok)
          end
        end

        describe '404 on resource show' do
          it 'returns 404 for non-existing vegetable', :lobanov do
            get(:show, params: { id: '999' })

            expect(response).to have_http_status(404)
          end
        end

        describe '401 on resource show' do
          it 'returns 401 for non-authorized vegetable', :lobanov do
            get(:show, params: { id: '666' })

            expect(response).to have_http_status(401)
          end
        end

        describe '400 on POST new vegetable' do
          it 'returns 400 for incorrect params', :lobanov do
            post(:create, params: { color: 'green' }, as: :json)

            expect(response).to have_http_status(400)
          end
        end

        describe '201 on POST vegetables/:id/upvote' do
          it 'returns 201', :lobanov do
            post(:upvote, params: { id: '5' })

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

    Given a file named "frontend/api-backend-specification/private/v6/components/schemas/VegetableName.yaml" with:
    """yaml
    ---
    type: string
    example: potato
    """

    When I run `rspec`

    Then the examples should all pass

    Then a yaml named "frontend/api-backend-specification/wapi/index.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v6/index.yaml" should contain:
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
            example: 'true'
        put:
          description: PUT /vegetables/:id
          operationId: VegetablesUpdate
          responses:
            '200':
              description: PUT /vegetables/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesUpdate200Response.yaml"
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
                  "$ref": "./components/requestBodies/VegetablesUpdateRequestBody.yaml"
        delete:
          description: DELETE /vegetables/:id
          operationId: VegetablesDestroy
          responses:
            '200':
              description: DELETE /vegetables/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesDestroy200Response.yaml"
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
      "/api/v6/vegetables":
        get:
          description: GET /vegetables
          operationId: VegetablesIndex
          responses:
            '200':
              description: GET /vegetables -> 200
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesIndex200Response.yaml"
          tags:
          - lobanov
        post:
          description: POST /vegetables
          operationId: VegetablesCreate
          responses:
            '201':
              description: POST /vegetables -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesCreate201Response.yaml"
            '400':
              description: POST /vegetables -> 400
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesCreate400Response.yaml"
          tags:
          - lobanov
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  "$ref": "./components/requestBodies/VegetablesCreateRequestBody.yaml"
      "/api/v6/vegetables/{id}/upvote":
        post:
          description: POST /vegetables/:id/upvote
          operationId: VegetablesUpvote
          responses:
            '201':
              description: POST /vegetables/:id/upvote -> 201
              content:
                application/json:
                  schema:
                    "$ref": "./components/responses/VegetablesUpvote201Response.yaml"
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

    # ============= RESPONSES =============

    Then a file named "frontend/api-backend-specification/wapi/components/responses/FruitsIndex200Response.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/wapi/components/responses/FruitsShow200Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/wapi/components/responses/FruitsCreate400Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/wapi/components/responses/FruitsShow401Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/wapi/components/responses/FruitsShow404Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a file named "frontend/api-backend-specification/wapi/components/responses/FruitsReviewsShow200Response.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/wapi/components/responses/FruitsReviewsIndex200Response.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/wapi/components/responses/FruitsReviewsStats200Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesIndex200Response.yaml" should contain:
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
                example: tomato
              color:
                type: string
                example: red
              weight:
                type: integer
                example: 100
              seasonal:
                type: boolean
                example: false
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesCreate201Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesCreate400Response.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesDestroy200Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesShow401Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesShow404Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesUpdate200Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/responses/VegetablesUpvote201Response.yaml" should contain:
      """yaml
      ---
      type: object
      properties: {}
      """

    # ============= REQUEST BODIES =============

    Then a yaml named "frontend/api-backend-specification/wapi/components/requestBodies/FruitsUpdateRequestBody.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/wapi/components/requestBodies/FruitsCreateRequestBody.yaml" should contain:
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

    Then a file named "frontend/api-backend-specification/wapi/components/requestBodies/FruitsUpvoteRequestBody.yaml" should not exist

    Then a file named "frontend/api-backend-specification/wapi/components/requestBodies/FruitsReviewsCreateRequestBody.yaml" should contain:
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

    Then a yaml named "frontend/api-backend-specification/private/v6/components/requestBodies/VegetablesCreateRequestBody.yaml" should contain:
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
          example: carrot
        color:
          type: string
          example: orange
        weight:
          type: integer
          example: 150
        seasonal:
          type: boolean
          example: true
      """

    Then a yaml named "frontend/api-backend-specification/private/v6/components/requestBodies/VegetablesUpdateRequestBody.yaml" should contain:
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
          example: carrot
        color:
          type: string
          example: orange
        weight:
          type: integer
          example: 150
        seasonal:
          type: boolean
          example: true
      """
