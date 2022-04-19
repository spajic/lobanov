# frozen_string_literal: true

module Lobanov
  # Generates OpenAPI v3 schema for path_params of Interaction
  class PathParamsGenerator
    attr_reader :params # Hash

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      return if params.empty?

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
        'schema' => { 'type' => 'string' },
        'required' => true,
        'example' => value.to_s
      }
    end
  end
end
