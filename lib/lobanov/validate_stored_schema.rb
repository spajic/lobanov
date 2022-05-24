# frozen_string_literal: true

module Lobanov
  # Validates stored_schema and returns validation error for particular conditions
  # Schemas are ruby objects representing OpenApi3 schema
  class ValidateStoredSchema
    attr_reader :stored_schema, :operation_id

    def self.call(*params)
      new(*params).call
    end

    def initialize(stored_schema:, operation_id:)
      @stored_schema = stored_schema
      @operation_id = operation_id
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

    def raise_error(missing_type_paths, missing_example_paths)
      error = {
        operation_id: operation_id,
        missing_types: missing_type_paths,
        missing_examples: missing_example_paths
      }

      exception = MissingTypeOrExampleError.new(format_error(error))
      exception.set_backtrace(['(ノಠ益ಠ)ノ彡┻━┻'])
      raise exception
    end

    def format_error(error)
      res = +"Problem with #{error[:operation_id]}\n"
      res << "\nMissing types:\n"
      error[:missing_types].each { |err| res << err << "\n" }
      res << "\nMissing examples:\n"
      error[:missing_examples].each { |err| res << err << "\n" }

      res.gsub!('->properties->', '->')

      res
    end
  end
end
