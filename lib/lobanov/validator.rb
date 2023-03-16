# frozen_string_literal: true

module Lobanov
  # Validates new_schema vs stored_schema and returns validation error
  # Schemas are ruby objects representing OpenApi3 schema
  class Validator
    UNNECESSARY_FIELDS = %w[description example openapi info required enum minItems].freeze

    def self.call(...)
      new(...).call
    end

    def initialize(new_schema:, stored_schema:)
      @new_schema = new_schema
      @stored_schema = stored_schema
    end

    def call
      ProcessEmptyArrays.call(new_schema: new_schema, stored_schema: stored_schema)
      ProcessNullable.call(new_schema: new_schema, stored_schema: stored_schema)
      ProcessEnums.call(new_schema: new_schema, stored_schema: stored_schema)
      prepared_new_schema = remove_unnecessary_fields(new_schema)
      prepared_stored_schema = remove_unnecessary_fields(stored_schema)

      return if prepared_new_schema == prepared_stored_schema

      format_error(prepared_new_schema, prepared_stored_schema)
    end

    private

    attr_reader :new_schema, :stored_schema

    # TODO: переписать на Visitor
    def remove_unnecessary_fields(schema)
      return unless schema.is_a?(Hash)

      schema.each do |key, value|
        remove_unnecessary_fields_step(schema, key, value)
      end

      schema
    end

    def remove_unnecessary_fields_step(schema, key, value)
      if UNNECESSARY_FIELDS.include? key
        schema.delete key
      elsif value.is_a?(Array)
        value.each { |v| remove_unnecessary_fields(v) }
      elsif value.is_a?(Hash)
        remove_unnecessary_fields(value)
      end
    end

    def format_error(new_schema, stored_schema)
      require 'diffy'
      new_yaml = YAML.dump new_schema
      stored_yaml = YAML.dump stored_schema
      Diffy::Diff.new(stored_yaml, new_yaml).to_s
    end
  end
end
