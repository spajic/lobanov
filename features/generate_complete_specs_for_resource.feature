Feature: generate complete specs for resource
  When you write lobanov specs for /resources CRUD + errors

  Scenario: basic usage
    When I cd to "../../test_apps/rails_61"

    Given a file named "frontend/api-backend-specification/index.yaml" with:
      """yaml
      ---
      paths: {}
      components:
        schemas: {}
      """

    Given an empty directory "frontend/api-backend-specification/components"

    Given an empty directory "frontend/api-backend-specification/paths"

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

        describe 'GET #show' do
          it 'returns expected resource', :lobanov do
            get(:show, params: {id: 2})

            expect(response).to have_http_status(:ok)
            expect(json_body).to eq({name: 'lemon', color: 'yellow', weight: 50, seasonal: false})
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
      end
      """

    When I run `rspec spec/controllers/fruits_controller_spec.rb`

    Then the example should pass

    Then a yaml named "frontend/api-backend-specification/index.yaml" should contain:
    """yaml
    ---
    paths:
      "/fruits":
        "$ref": "./paths/fruits/path.yaml"
      "/fruits/{id}":
        "$ref": "./paths/fruits/[id]/path.yaml"
    components:
      schemas:
        FruitsIndexResponse:
          "$ref": "./components/FruitsIndexResponse.yaml"
        FruitsShowResponse:
          "$ref": "./components/FruitsShowResponse.yaml"
        FruitsCreateResponse:
          "$ref": "./components/FruitsCreateResponse.yaml"
        FruitsUpdateResponse:
          "$ref": "./components/FruitsUpdateResponse.yaml"
        FruitsDestroyResponse:
          "$ref": "./components/FruitsDestroyResponse.yaml"
        400Response:
          "$ref": "./components/400Response.yaml"
        401Response:
          "$ref": "./components/401Response.yaml"
        404Response:
          "$ref": "./components/404Response.yaml"
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
                "$ref": "../../components/FruitsCreateRequestBody"
        responses:
          '201':
            description: POST /fruits -> 201
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsCreateResponse.yaml"
          '400':
            description: POST /fruits -> 400
            content:
              application/json:
                schema:
                  "$ref": "../../components/400Response.yaml"
      get:
        responses:
          '200':
            description: GET /fruits -> 200
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsIndexResponse.yaml"
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
                  "$ref": "../../../components/FruitsUpdateRequestBody"
          responses:
            '200':
              description: PUT /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsUpdateResponse.yaml"
        get:
          parameters:
          - in: path
            name: id
            description: id
            schema:
              type: integer
            required: true
            example: '2'
          responses:
            '200':
              description: GET /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsShowResponse.yaml"
            '404':
              description: GET /fruits/:id -> 404
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/404Response.yaml"
            '401':
              description: GET /fruits/:id -> 401
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/401Response.yaml"
        delete:
          responses:
            '200':
              description: DELETE /fruits/:id -> 200
              content:
                application/json:
                  schema:
                    "$ref": "../../../components/FruitsDestroyResponse.yaml"
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

      Then a file named "frontend/api-backend-specification/components/FruitsIndexResponse.yaml" should contain:
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

      Then a file named "frontend/api-backend-specification/components/FruitsShowResponse.yaml" should contain:
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

        Then a yaml named "frontend/api-backend-specification/components/400Response.yaml" should contain:
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

          Then a yaml named "frontend/api-backend-specification/components/401Response.yaml" should contain:
            """yaml
            ---
            type: object
            properties: {}
            """

          Then a yaml named "frontend/api-backend-specification/components/404Response.yaml" should contain:
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
