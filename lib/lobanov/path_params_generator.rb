# frozen_string_literal: true

module Lobanov
  # Generates OpenAPI v3 schema for path_params of Interaction
  class PathParamsGenerator
    attr_reader :params

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      return if params.blank?

      params.reject! { |name, _value| %w[controller action].include? name }
      return if params.empty?

      params.map { |name, value| schema_for_path_param(name, value) }
    end

    private

    def schema_for_path_param(name, value)
      {
        'in' => 'path',
        'name' => name,
        'description' => name,
        'schema' => schema_by_path_param_value(value),
        'required' => true,
        'example' => value
      }
    end

    def schema_by_path_param_value(value)
      if a_positive_integer?(value)
        {'type' => 'integer'}
      else
        {'type' => 'string'}
      end
    end

    def a_positive_integer?(str)
      /\A\d+\z/.match(str)
    end
  end
end
