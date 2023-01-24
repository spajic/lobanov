# frozen_string_literal: true

module Lobanov
  class LoadResponseSchema
    attr_reader :path_with_curly_braces, :verb, :status, :api_marker

    def initialize(path_with_curly_braces:, verb:, status:, api_marker:)
      @path_with_curly_braces = path_with_curly_braces
      @verb = verb
      @status = status
      @api_marker = api_marker
    end

    def call
      begin
        index = YAML.load_file(index_path)
      rescue Errno::ENOENT
        return
      end
      response_schema_file_name = index.dig(*dig_args)
      return nil unless response_schema_file_name

      loaded_schema = Support.read_relative(response_schema_file_name, api_marker)
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

        ref_content = Support.read_relative(ref_file, api_marker)
        return ref_content if path == [] # only $ref in a file

        loaded_schema.dig(*path[0..-2])[path.last] = ref_content
      end

      loaded_schema
    end

    def index_path
      if api_marker == 'wapi'
        "#{Lobanov.specification_folder}/wapi/index.yaml"
      else
        version_number = api_marker.last
        "#{Lobanov.specification_folder}/private/v#{version_number}/index.yaml"
      end
    end
  end
end
