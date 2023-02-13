# frozen_string_literal: true

module Lobanov
  # Given a schema Hash, returns an Enumerator of all nodes, that are references to external schemas
  # Each node is a Hash with two keys: :path and :value
  # :path is an array of string keys, that can be used to access the node in the schema
  # :value is the value of the node
  # Example:
  # {
  #   path: ['paths', '/users', 'get', 'responses', '200', 'content', 'application/json', 'schema']
  #   value: { '$ref' => './components/responses/UsersIndex200Response.yaml' }
  # }
  class RefVisitor
    def self.visit(schema)
      new.visit(schema)
    end

    def visit(schema)
      Enumerator.new do |visitor|
        go(schema, [], visitor)
      end
    end

    private

    # path is array of string keys
    def go(schema, path, visitor)
      current_position = (path == [] ? schema : schema.dig(*path))

      if ref_node?(current_position)
        visitor << { path: path, value: current_position }
      elsif current_position.is_a?(Hash)
        current_position.keys.each { |key| go(schema, path + [key], visitor) }
      end
    end

    def ref_node?(current_position)
      return false unless current_position.is_a?(Hash)
      return false unless current_position.keys == ['$ref']

      ref = current_position['$ref']
      ref.is_a?(String) && !ref.start_with?('#')
    end
  end
end
