# frozen_string_literal: true

module Lobanov
  class SchemaByObject
    UNWANTED_FIELDS = %w[$schema description].freeze
    COMMENT_FOR_GENERATED_SCHEMA = ''

    def self.call(obj)
      require 'json-schema-generator'
      serialized_schema = JSON::SchemaGenerator.generate(
        COMMENT_FOR_GENERATED_SCHEMA,
        JSON.dump(obj),
        schema_version: 'draft4'
      )
      schema = JSON.parse(serialized_schema)
      remove_unwanted_fields(schema)
      add_examples_to_schema(schema, obj)
    end

    def self.remove_unwanted_fields(schema)
      UNWANTED_FIELDS.each { |field| schema.delete field }
      schema
    end

    def self.add_examples_to_schema(schema, obj)
      obj.each_key do |key|
        property = obj[key]
        skey = key.is_a?(Symbol) ? key.to_s : key
        case property
        when Hash
          add_examples_to_schema(schema['properties'][skey], obj[key])
        when Array
          example = obj[key].detect(&:present?)
          if schema['properties'][skey]['items'].present?
            add_examples_to_schema(schema['properties'][skey]['items'], example)
          end
        else
          schema['properties'][skey]['example'] = obj[key]
        end
      end

      schema
    end
  end
end
