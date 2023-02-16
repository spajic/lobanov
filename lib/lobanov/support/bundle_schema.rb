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

        RefToRegisterVisitor.visit(
          schema: schema, 
          registered_components: registered_components(schema, index_folder),
          current_folder: index_folder,
        ).each do |node|
          path = node[:path]
          component_ref = node[:value]
          schema.dig(*path[0..-2])[path.last] = component_ref
        end

        expanded_schema = ExpandRefs.call(schema, index_folder)
        File.write("#{index_folder}/#{output_file_name}", expanded_schema.to_yaml)
      end

      def self.registered_components(schema, index_folder)
        CollectRegisteredComponents.call(
          components_section: schema['components'],
          root_folder: index_folder
        )
      end
    end
  end
end

