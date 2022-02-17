# frozen_string_literal: true
require 'pry'

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
      if obj.is_a?(Hash)
        obj.each_key do |key|
          add_example_for_key(schema, obj, key)
        end
      elsif obj.is_a?(Array)
        add_examples_to_schema(schema['items'], obj.first)
      else
        schema['example'] = obj
      end

      schema
    end

    def self.add_example_for_key(schema, obj, key)
      property = obj[key]
      skey = key.to_s

      case property
      when Hash
        add_examples_to_schema(schema['properties'][skey], obj[key])
      when Array
        example = obj[key].detect {|hash| !hash.empty?}
        unless schema['properties'][skey]['items'].empty?
          add_examples_to_schema(schema['properties'][skey]['items'], example)
        end
      else
        example = obj[key]
        # Не разрешаем добавить в тест поле, но не дать реального примера
        # по nil мы не можем на вывести тип
        # пустая строка тоже плохо, лучше в качестве примера дать заполненную
        if example.nil? || example == ''
          raise MissingExampleError.new("for #{key.inspect} in #{obj}")
        end
        schema['properties'][skey]['example'] = example
      end
    end
  end
end
