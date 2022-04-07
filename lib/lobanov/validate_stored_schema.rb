# frozen_string_literal: true

module Lobanov
  # Validates stored_schema and returns validation error for particular conditions
  # Schemas are ruby objects representing OpenApi3 schema
  class ValidateStoredSchema
    def self.call(stored_schema:)
      missing_type_paths = []
      missing_example_paths = []

      Visitor.visit(stored_schema).each do |node|
        path = node[:path]
        value = node[:value]

        if value['type'].nil?
          missing_type_paths << path.join('->')
        end

        if value['example'].nil?
          missing_example_paths << path.join('->')
        end
      end

      return if [missing_type_paths, missing_example_paths].all?(&:empty?)

      error = {
        missing_types: missing_type_paths,
        missing_examples: missing_example_paths,
      }.inspect

      raise MissingTypeOrExampleError.new(error)
    end
  end
end
