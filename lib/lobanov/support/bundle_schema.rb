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
        expanded_schema = ExpandRefs.call(schema, index_folder)
        File.write("#{index_folder}/#{output_file_name}", expanded_schema.to_yaml)
      end
    end
  end
end

