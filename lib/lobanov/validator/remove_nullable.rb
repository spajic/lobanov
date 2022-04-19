# frozen_string_literal: true

# Removes nullables from schema

# TODO: надо обойти все элементы stored_schema
# для каждого
#   если есть соответствующий элемент в new_schema - оставляем
#   если нет соответствующего ключа - удаляем из stored_schema если не required поле
#   если нет соответствующего значения - удаляем из обоих схем если nullable
module Lobanov
  class Validator
    class RemoveNullable
      def self.call(*params)
        new(*params).call
      end

      attr_reader :new_schema, :stored_schema

      def initialize(new_schema:, stored_schema:)
        @new_schema = new_schema
        @stored_schema = stored_schema
      end

      def call
        Visitor.visit(stored_schema).each do |node|
          process_node(node)
        end
      end

      private

      def process_node(node)
        path = node[:path]
        stored_value = node[:value]
        new_value = new_schema.dig(*path)

        # так бывает, если уже удалили все nulable поля в объекте и ничего не осталось
        return if new_value == {} && stored_value == {}

        if new_value.nil?
          process_nil_value(path)
        elsif new_value['type'].nil?
          process_nil_type(path, stored_value)
        end

        process_empty_properties(path) if empty_properties?(path, stored_value)
      end

      def process_empty_properties(path)
        stored_schema.dig(*path[0..-3]).delete(path[-2])
        new_schema.dig(*path[0..-3])&.delete(path[-2])
      end

      def empty_properties?(path, stored_value)
        path.last == 'properties' && path.size > 1 && stored_value == {}
      end

      def process_nil_value(path)
        requireds_path = path[0..-3] + ['required']
        required_fields = stored_schema.dig(*requireds_path)
        field_name = path.last

        raise MissingRequiredFieldError, path.join('->') if required_fields&.include?(field_name)

        stored_schema.dig(*path[0..-2]).delete(path.last)
      end

      def process_nil_type(path, stored_value)
        parent_path = path[0..-2]

        return if parent_path == []

        raise MissingNotNullableValueError, path.join('->') unless nil_type?(stored_value, parent_path)

        stored_schema.dig(*parent_path).delete(path.last)
        new_schema.dig(*parent_path).delete(path.last)
      end

      def nil_type?(stored_value, parent_path)
        stored_value['nullable'] ||
          (parent_path != [] && (stored_schema.dig(*parent_path)['minItems']).zero?)
      end
    end
  end
end
