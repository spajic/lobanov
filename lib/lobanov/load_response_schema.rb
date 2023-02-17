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
        index = YAML.load_file(base_path.join('index.yaml'))
      rescue Errno::ENOENT
        return
      end
      response_schema_file_name = index.dig(*dig_args)
      return nil unless response_schema_file_name

      loaded_schema = YAML.load_file(base_path.join(response_schema_file_name))
      Lobanov::Support::ExpandRefs.call(
        loaded_schema,
        base_path.join('components/responses').to_s, 
        registered_components: {}
      )
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

    def base_path
      path = 
        if api_marker == 'wapi'
          "#{Lobanov.specification_folder}/wapi"
        else
          version_number = api_marker.last
          "#{Lobanov.specification_folder}/private/v#{version_number}"
        end
      Pathname.new(path)
    end
  end
end
