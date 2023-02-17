# frozen_string_literal: true

module Lobanov
  module Support
    # Takes a schema, stored in a folder and subfolders, consisting of different files
    # And bundles it into single yaml file
    #
    # Usage: Lobanov::Support::BundleSchema.call for defatults
    # Lobanov::Support::BundleSchema.call(index_folder: 'another_path', output_file_name: 'another_bundle.yaml')
    class BundleSchema
      def self.call(index_folder: Lobanov.specification_folder, output_file_name: 'openapi_single.yaml')
        schema = YAML.load_file("#{index_folder}/index.yaml")
        registered_components = collect_registered_components(schema, index_folder)
        ExpandRefs.call(schema, index_folder, registered_components: registered_components)
        File.write("#{index_folder}/#{output_file_name}", schema.to_yaml)
      end

      def self.collect_registered_components(schema, index_folder)
        CollectRegisteredComponents.call(
          components_section: schema['components'],
          root_folder: index_folder
        )
      end

      def self.use_registered_components!(schema:, index_folder:, registered_components:)
        RefToRegisterVisitor.visit(
          schema: schema, 
          registered_components: registered_components,
          current_folder: index_folder,
        ).each do |node|
          path = node[:path]
          component_ref = node[:value]
          schema.dig(*path[0..-2])[path.last] = component_ref
        end
      end
    end
  end
end

