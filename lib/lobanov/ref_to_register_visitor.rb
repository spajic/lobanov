# frozen_string_literal: true

module Lobanov
  # Given a schema Hash and a registered_components Hash, returns an Enumerator of all nodes, 
  # thas should be replaced with registered components
  #
  # Each returned node is a Hash with two keys: :path and :value
  # :path is an array of string keys, that can be used to access the node in the schema
  # :value is the value of the node
  # Example:
  # {
  #   path: ['paths', '/users', 'get', 'responses', '200', 'content', 'application/json', 'schema']
  #   value: { '$ref' => './components/responses/UsersIndex200Response.yaml' }
  # }
  class RefToRegisterVisitor
    attr_reader :registered_components
    attr_reader :current_folder

    def self.visit(schema:, registered_components:, current_folder:)
      new.visit(schema: schema, registered_components: registered_components, current_folder: current_folder)
    end

    def visit(schema:, registered_components:, current_folder:)
      @registered_components = registered_components
      @current_folder = current_folder

      Enumerator.new do |visitor|
        go(schema, [], visitor)
      end
    end

    private

    # path is array of string keys
    def go(schema, path, visitor)
      current_position = (path == [] ? schema : schema.dig(*path))

      return if path[0] == 'components' 

      if ref_to_register_node?(current_position)
        visitor << { path: path, value: current_position }
      elsif ref_node?(current_position)
        # TODO: process the node recursively
      elsif current_position.is_a?(Hash)
        current_position.keys.each { |key| go(schema, path + [key], visitor) }
      end
    end

    def ref_to_register_node?(current_position)
      return false unless current_position.is_a?(Hash)
      return false unless current_position.keys == ['$ref']

      # TODO: transform to absolute path here
      ref = current_position['$ref']
      ref.is_a?(String) && registered_components.key?(ref)
    end

    def ref_node?(current_position)
      return false unless current_position.is_a?(Hash)
      return false unless current_position.keys == ['$ref']

      ref = current_position['$ref']
      ref.is_a?(String) && !ref.start_with?('#')
    end
  end
end
