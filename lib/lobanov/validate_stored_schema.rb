# frozen_string_literal: true

module Lobanov
  # Validates stored_schema and returns validation error for particular conditions
  # Schemas are ruby objects representing OpenApi3 schema
  class ValidateStoredSchema
    def self.call(*params)
      new(*params).call
    end

    def initialize(stored_schema:)
      @stored_schema = stored_schema
    end

    def call
      missing_type_paths = []
      missing_example_paths = []

      Visitor.visit(stored_schema).each do |node|
        path = node[:path]
        value = node[:value]

        missing_type_paths << path.join('->') if value['type'].nil?

        missing_example_paths << path.join('->') if value['example'].nil?
      end

      return if [missing_type_paths, missing_example_paths].all?(&:empty?)

      raise_error(missing_type_paths, missing_example_paths)
    end

    private

    attr_reader :stored_schema

    def raise_error(missing_type_paths, missing_example_paths)
      error = {
        missing_types: missing_type_paths,
        missing_examples: missing_example_paths
      }.inspect

      raise MissingTypeOrExampleError, error
    end
  end
end
