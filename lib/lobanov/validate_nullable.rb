# frozen_string_literal: true

module Lobanov
  # Validates stored_schema and returns validation error for particular conditions
  # Schemas are ruby objects representing OpenApi3 schema
  class ValidateNullable
    def self.call(stored_schema:)
      errors = []
      Visitor.visit(stored_schema).each do |node|
        path = node[:path]
        value = node[:value]

        next unless value['type'].nil? && (value['nullable'] || value['example'].nil)

        errors << path.join('->')
      end

      return if errors.empty?

      raise MissingNotNullableValueError.new(errors.join(",\n"))
    end
  end
end
