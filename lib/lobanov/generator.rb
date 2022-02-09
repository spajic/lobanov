# frozen_string_literal: true

module Lobanov
  # Generates OpenAPI v3 schema for Interaction
  # Output is Ruby object representing schema, it may be serialized to yml|json
  class Generator
    extend Forwardable

    attr_reader :interaction

    def_delegator :@interaction, :verb
    def_delegator :@interaction, :endpoint_path
    def_delegator :@interaction, :controller_action
    def_delegator :@interaction, :path_info
    def_delegator :@interaction, :path_params
    def_delegator :@interaction, :query_params
    def_delegator :@interaction, :payload
    def_delegator :@interaction, :body
    def_delegator :@interaction, :status

    def initialize(interaction:)
      @interaction = interaction
    end

    def call
      {
        'paths' => paths
      }
    end

    def component_schema
      SchemaByObject.call(body)
    end

    def response_component_name
      parts = path_parts_without_ids.map(&:capitalize) + [controller_action.capitalize]
      if parts[-1] == parts[-2] # /fruits/:id/reviews/:review_id/upvote
        parts.pop
      end

      parts.join + 'Response'
    end

    def path_with_square_braces
      "/#{path_name}" # TODO: refactor
    end

    def path_parts
      path_with_square_braces.split('/') - [""]
    end

    def path_parts_without_ids
      path_parts.reject { |part| part.start_with?('[') }
    end

    def paths
      @paths ||= {
        path_with_curly_braces => {
          verb.downcase => verb_schema
        }
      }
    end

    def path_schema
      raise 'Only support ONE path per interaction' unless paths.size == 1

      key = paths.keys.first
      paths[key]
    end

    # путь вида wapi/grid_bots/:id  -> wapi/grid_bots/GridBot
    # путь вида wapi/grid_bots -> wapi/grid_bots/GridBots
    def component_name
      ComponentNameByPath.call(endpoint_path)[:full]
    end

    def component_only_name
      ComponentNameByPath.call(endpoint_path)[:name]
    end

    # TODO: refactor
    def component_namespace
      ComponentNameByPath.call(endpoint_path)[:namespace]
    end

    # /wapi/grid_bots/:id -> wapi/grid_bots/[id]
    # users/:user_id/pets/:pet_id -> users/[user_id]/pets/[pet_id]
    def path_name
      res = endpoint_path.dup.gsub(%r{^/}, '') # убираем /, если строка начинается с него
      ids = res.scan(/(:\w*)/).flatten # [':user_id', ':pet_id']
      ids.each do |id|
        res.gsub!(id, "[#{id.gsub(':', '')}]")
      end

      res
    end

    def path_with_curly_braces
      endpoint_path.gsub(/:(\w*)/) { |_s| "{#{Regexp.last_match(1)}}" }
    end

    private

    def verb_schema
      params_schema = parameters_schema
      if params_schema
        {
          'parameters' => params_schema,
          'responses' => response_schema
        }
      else
        {'responses' => response_schema}
      end
    end

    def parameters_schema
      schema = (Array(path_params_schema) + Array(query_params_schema)).compact
      schema.empty? ? nil : schema
    end

    def path_params_schema
      PathParamsGenerator.call(path_params)
    end

    def query_params_schema
      QueryParamsGenerator.call(query_params)
    end

    def response_schema
      {
        status.to_s => {
          'description' => "#{verb} #{endpoint_path} -> #{status}",
          'content' => {
            'application/json' => {
              'schema' => SchemaByObject.call(body)
            }
          }
        }
      }
    end
  end
end
