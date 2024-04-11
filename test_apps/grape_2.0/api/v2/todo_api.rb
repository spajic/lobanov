# frozen_string_literal: true

module API
  module V2
    PLANS = [
      {id: 1, title: 'Todo #1', description: 'Wake up, Neo', created_at: Time.local(2024, 4, 11).to_i},
      {id: 2, title: 'Todo #2', description: 'Go to the Matrix', created_at: Time.local(2024, 4, 11).to_i},
      {id: 3, title: 'Todo #3', description: 'Have a rest', created_at: Time.local(2024, 4, 11).to_i}
    ]

    class TodoApi < Grape::API
      namespace :api do
        namespace 'v2' do
          resource :todos do
            desc 'Todo list'
            route_setting :action, :list
            get do
              present PLANS.to_json
            end

            desc 'Create Todo'
            route_setting :action, :create
            post do
              present PLANS.last.to_json
            end

            route_param :id, type: Integer do
              desc 'Show Todo'
              route_setting :action, :show
              get do
                present PLANS.last.to_json
              end

              desc 'Update Todo'
              route_setting :action, :update
              put do
                present PLANS.last.to_json
              end

              desc 'Delete Todo'
              route_setting :action, :delete
              delete do
                present({success: true}.to_json)
              end
            end
          end
        end
      end
    end
  end
end