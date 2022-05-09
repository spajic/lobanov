# frozen_string_literal: true

module Lobanov
  class ProcessEnums
    def self.call(*params)
      new(*params).call
    end

    attr_reader :new_schema, :stored_schema

    def initialize(new_schema:, stored_schema:)
      @new_schema = new_schema
      @stored_schema = stored_schema
    end

    def call
      Visitor.visit(stored_schema).each do |stored_node|
        process_node(stored_node)
      end
    end

    private

    def process_node(stored_node)
      stored_value = stored_node[:value]

      enum = stored_value['enum']
      return unless enum

      path = stored_node[:path]
      new_value = new_schema.dig(*path)

      check_example_belongs_to_enum!(stored_value['example'], enum, path, 'stored')
      check_example_belongs_to_enum!(new_value['example'], enum, path, 'new')
    end

    def check_example_belongs_to_enum!(example, enum, path, schema_type)
      return if enum.include?(example)

      msg = "Invalid enum value in #{schema_type} schema! #{path.join('->')}. \n"\
        "Expected #{enum}, got #{example.inspect}"
      raise InvalidEnumError, msg
    end
  end
end
