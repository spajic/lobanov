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
          it 'returns expected response with 200 and empty body' do
            put(:update, params: apple)

            expect(response).to have_http_status(:ok)
          end
        end
      end
      """

    When I run `rspec spec/controllers/fruits_controller_spec.rb`

    Then the example should pass

    Then a file named "frontend/api-backend-specification/index.yaml" should contain:
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
        responses:
          '201':
            description: POST /fruits -> 201
            content:
              application/json:
                schema:
                  "$ref": "../../components/FruitsCreateResponse.yaml"
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
