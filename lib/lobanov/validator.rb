# frozen_string_literal: true

module Lobanov
  # Validates new_schema vs stored_schema and returns validation error
  # Schemas are ruby objects representing OpenApi3 schema
  class Validator
    UNNECESSARY_FIELDS = %w[description example openapi info].freeze

    def self.call(new_schema:, stored_schema:)
      prepared_new_schema = remove_unnecessary_fields(new_schema)
      prepared_stored_schema = remove_unnecessary_fields(stored_schema)
      remove_nullable!(new_schema, stored_schema)
      # remove_empty_props!(stored_schema)

      return if prepared_new_schema == prepared_stored_schema

      format_error(prepared_new_schema, prepared_stored_schema)
    end

    def self.remove_unnecessary_fields(schema)
      return unless schema.is_a?(Hash)

      schema.each do |key, value|
        if UNNECESSARY_FIELDS.include? key
          schema.delete key
        elsif value.is_a?(Array)
          value.each { |v| remove_unnecessary_fields(v) }
        elsif value.is_a?(Hash)
          remove_unnecessary_fields(value)
        end
      end

      schema
    end

    # TODO: надо обойти все элементы stored_schema
    # для каждого
    #   если есть соответствующий элемент в new_schema - оставляем
    #   если нет соответствующего ключа - удаляем из stored_schema если не required поле
    #   если нет соответствующего значения - удаляем из обоих схем если nullable
    def self.remove_nullable!(new_schema, stored_schema)
      visit(stored_schema).each do |node|
        path = node[:path]
        stored_value = node[:value]
        new_value = new_schema.dig(*path)

        if new_value.nil?
          requireds_path = path[0..-3] + ['required']
          required_fields = stored_schema.dig(*requireds_path)
          field_name = path.last

          if required_fields&.include?(field_name)
            raise MissingRequiredFieldError, path.join('->')
          else
            stored_schema.dig(*path[0..-2]).delete(path.last)
          end
        elsif new_value['type'].nil?
          parent_path = path[0..-2]

          if parent_path == []
            # do nothing
          elsif stored_value['nullable'] ||
              (parent_path != [] && stored_schema.dig(*parent_path)['minItems'] == 0)
            stored_schema.dig(*parent_path).delete(path.last)
            new_schema.dig(*parent_path).delete(path.last)
          else
            raise MissingNotNullableValueError, path.join('->')
          end
        end

        if path.last == 'properties' && path.size > 1 && stored_value == {}
          stored_schema.dig(*path[0..-3]).delete(path[-2])
          new_schema.dig(*path[0..-3])&.delete(path[-2])
        end
      end
    end

    def self.visit(schema)
      Enumerator.new do |visitor|
        go(schema, [], visitor)
      end
    end

    # path is array of string keys
    def self.go(schema, path, visitor)
      current_position = (path == [] ? schema : schema.dig(*path))

      if current_position['type'] == 'object'
        props_path = path + ['properties']
        schema.dig(*props_path).each do |prop_name, prop_value|
          go(schema, props_path + [prop_name], visitor)
        end
        if schema.dig(*props_path) == {} # все пропсы удалили, или не было
          visitor << {path: props_path, value: {}}
        end
      elsif current_position['type'] == 'array' && current_position['items']
        go(schema, path + ['items'], visitor)
      else
        visitor << {path: path, value: current_position}
      end
    end

    def self.format_error(new_schema, stored_schema)
      require 'diffy'
      new_yaml = YAML.dump new_schema
      stored_yaml = YAML.dump stored_schema
      Diffy::Diff.new(stored_yaml, new_yaml).to_s
    end
  end
end
