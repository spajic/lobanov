# frozen_string_literal: true

module Lobanov
  module Support
    class CollectRegisteredComponents
      # Here we collect a hash from index.yaml components/schemas/* to their paths
      # keys are file paths, for example './components/schemas/Fruit.yaml'
      # values are registered components refs, for example '#/components/schemas/Fruit'
      def self.call(components_section:, root_folder:)
        schemas = components_section&.dig('schemas')
        return {} unless schemas

        registered_components = {}
        schemas.each do |(component_name, component_value)|
          # component_name is like 'Fruit' 
          # component value is like { '$ref' => './components/schemas/Fruit.yaml' }
          next unless component_value['$ref']
          
          path_from_root = Pathname.new(root_folder).join(component_value['$ref']) 
          registered_components[path_from_root.to_s] = "#/components/schemas/#{component_name}" 
        end

        registered_components
      end
    end
  end
end
