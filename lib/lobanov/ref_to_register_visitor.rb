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

    def self.visit(schema:, registered_components:, current_folder:)
      new.visit(schema: schema, registered_components: registered_components, current_folder: current_folder)
    end

    def visit(schema:, registered_components:, current_folder:)
      @registered_components = registered_components

      Enumerator.new do |visitor|
        go(schema, [], visitor, current_folder)
      end
    end

    private

    # path is array of string keys
    def go(schema, path, visitor, current_folder)
      current_position = (path == [] ? schema : schema.dig(*path))

      return if path[0] == 'components' 

      if ref_to_register_node?(current_position, current_folder)
        ref = current_position['$ref']
        expanded_value = Pathname.new(current_folder).join(ref).to_s
        visitor << { path: path, value: { '$ref' => registered_components[expanded_value] }}
      elsif ref_node?(current_position)
        ref_pathname = Pathname.new(current_folder).join(current_position['$ref'])
        ref_content = YAML.load_file(ref_pathname)
        schema.dig(*path[0..-2])[path.last] = ref_content
        go(schema, path, visitor, ref_pathname.parent.to_s)
      elsif current_position.is_a?(Hash)
        current_position.keys.each { |key| go(schema, path + [key], visitor, current_folder) }
      end
    end

    def ref_to_register_node?(current_position, current_folder)
      return false unless current_position.is_a?(Hash)
      return false unless current_position.keys == ['$ref']

      ref = current_position['$ref']
      return false unless ref.is_a?(String) 

      ref_path = Pathname.new(current_folder).join(ref).to_s
      registered_components.key?(ref_path)
    end

    def ref_node?(current_position)
      return false unless current_position.is_a?(Hash)
      return false unless current_position.keys == ['$ref']

      ref = current_position['$ref']
      ref.is_a?(String) && !ref.start_with?('#')
    end
  end
end
