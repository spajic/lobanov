# frozen_string_literal: true

module Lobanov
  # Если в stored_schema у массива разрешается minItems: 0
  # А в new_schema действительно пришёл пустой массив
  # то есть у него схема
  # type: array
  # minItems: 0
  # uniqueItems: true
  # items:
  #   example:
  #
  # То надо удалить items из new_schema и из stored_schema
  #
  # Если в stored_schema minItems > 0,
  # то не разрешаем minItems = 0 в new_schema
  class ProcessEmptyArrays
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
      return unless stored_value

      stored_min_items = stored_value['minItems']
      return unless stored_min_items&.zero?

      new_value = safe_dig(new_schema, stored_node[:path])
      new_min_items = new_value['minItems']
      return unless new_min_items&.zero?

      stored_value.delete('items')
      new_value.delete('items')
    end

    def safe_dig(schema, path)
      if path == []
        schema
      else
        schema.dig(*path)
      end
    end
  end
end
