# frozen_string_literal: true

module Lobanov
  class LoadResponseSchema
    attr_reader :path_with_curly_braces, :verb, :status

    def initialize(path_with_curly_braces:, verb:, status:)
      @path_with_curly_braces = path_with_curly_braces
      @verb = verb
      @status = status
    end

    def call
      index = YAML.load_file(Lobanov.specification_folder + '/index.yaml' )
      response_schema_file_name = index.dig(
        'paths',
        path_with_curly_braces,
        verb,
        'responses',
        status,
        'content',
        'application/json',
        'schema',
        '$ref'
      )
      return nil unless response_schema_file_name

      loaded_schema = Support.read_relative(response_schema_file_name)

      expand_refs!(loaded_schema)

      loaded_schema
    end

    private

    def expand_refs!(loaded_schema)
      props = loaded_schema['properties']
      props.each do |key, value|
        ref_file = value['$ref']
        if ref_file
          ref_content = Support.read_relative(ref_file)
          props[key] = ref_content
        end
      end
    end
  end
end
