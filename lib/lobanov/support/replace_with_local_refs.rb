# frozen_string_literal: true

module Lobanov
  module Support
    class ReplaceWithLocalRefs
      attr_reader :schema
      attr_reader :registered_components
      
      def self.call(schema:)
        new(schema: schema.call)
      end
      
      def initialize(schema:)
        @schema = schema
        @registered_components = {}
      end
      
      def call
        build_registered_components 
        replace_refs
      end

      private

      # Here we collect a hash from index.yaml components/schemas/* to their paths
      # keys are file paths, for example './components/schemas/Fruit.yaml'
      # values are registered components refs, for example '#/components/schemas/Fruit'
      def build_registered_components
        schema['components']['schemas'].each do |(component_name, component_value)|
          # component_name is like 'Fruit' 
          # component value is like { '$ref' => './components/schemas/Fruit.yaml' }
          registered_components[component_name] = component_value['$ref'] 
        end
      end

      def replace_refs
        Lobanov::RefVisitor.visit(schema).each do |node|
          value = node[:value]
          ref = value['$ref']
          if registered_components.key?(ref)
            # TODO: think here
          end
        end
        schema
      end
    end
  end
end

