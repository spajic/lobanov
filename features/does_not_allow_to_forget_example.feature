# TODO: сейчас выдаёт ошибку Lobanov::MissingExample, и это правильно,
# надо только оформить это в виде теста

# Feature: generate examples for nil values
#   When you generate schema for nil values it save empty string to example

#   Scenario: basic usage
#     When I cd to "../../test_apps/rails_61"

#     Given a file named "spec/controllers/fruits_controller_spec.rb" with:
#       """ruby
#       require 'rails_helper'

#       RSpec.describe FruitsController, type: :controller do
#         describe 'GET #show' do
#           it 'returns expected response', :lobanov do
#             get(:show, params: {id: 1})

#             expect(response).to have_http_status(:ok)
#             expect(json_body).to eq({color: nil})
#           end
#         end
#       end
#       """

#     Given a file named "frontend/api-backend-specification/index.yaml" with:
#       """yaml
#       ---
#       paths: {}
#       components:
#         schemas: {}
#       """

#     Given an empty directory "frontend/api-backend-specification/components"

#     Given an empty directory "frontend/api-backend-specification/paths"

#     When I run `rspec spec/controllers/fruits_controller_spec.rb`

#     Then the example should pass

#     Then a file named "frontend/api-backend-specification/components/Fruit.yaml" should contain:
#     """yaml
#     ---
#     type: object
#     required:
#     - color
#     properties:
#       color:
#         example: ''
#     """
