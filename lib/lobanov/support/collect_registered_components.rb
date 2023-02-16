# frozen_string_literal: true

module Lobanov
  module Support
    class CollectRegisteredComponents
      # Here we collect a hash from index.yaml components/schemas/* to their paths
      # keys are file paths, for example './components/schemas/Fruit.yaml'
      # values are registered components refs, for example '#/components/schemas/Fruit'
      def self.call(components_section:)
        registered_components = {}
        components_section['schemas'].each do |(component_name, component_value)|
          # component_name is like 'Fruit' 
          # component value is like { '$ref' => './components/schemas/Fruit.yaml' }
          next unless component_value['$ref']

          registered_components[component_value['$ref']] = "#/components/schemas/#{component_name}" 
        end

        registered_components
      end
    end
  end
end
