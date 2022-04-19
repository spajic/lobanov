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
      index = YAML.load_file("#{Lobanov.specification_folder}/index.yaml")
      response_schema_file_name = index.dig(*dig_args)
      return nil unless response_schema_file_name

      loaded_schema = Support.read_relative(response_schema_file_name)
      expand_refs!(loaded_schema)
    end

    private

    def dig_args
      ['paths',
       path_with_curly_braces,
       verb,
       'responses',
       status,
       'content',
       'application/json',
       'schema',
       '$ref']
    end

    def expand_refs!(loaded_schema)
      Visitor.visit(loaded_schema).each do |node|
        path = node[:path]
        value = node[:value]

        ref_file = value['$ref']
        next unless ref_file

        ref_content = Support.read_relative(ref_file)
        return ref_content if path == [] # only $ref in a file

        loaded_schema.dig(*path[0..-2])[path.last] = ref_content
      end

      loaded_schema
    end
  end
end
