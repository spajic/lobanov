# frozen_string_literal: true

src = File.expand_path('support/inflector/*.rb', __dir__)
files = Dir.glob(src)
files.each { |file| require file }

module Lobanov
  module Support
    def self.singularize(str)
      Inflector.singularize(str)
    end

    def self.camelize(str)
      Inflector.camelize(str)
    end

    def self.read_relative(relative_path, api_marker)
      api_marker_path =
        if api_marker == 'wapi'
          'wapi'
        else
          version_number = api_marker.last
          "private/v#{version_number}"
        end

      full_path =
        if relative_path.start_with?('../schemas/')
          path = relative_path.gsub('../schemas/', '')
          "#{Lobanov.specification_folder}/#{api_marker_path}/components/schemas/#{path}"
        else
          "#{Lobanov.specification_folder}/#{api_marker_path}/#{relative_path}"
        end

      YAML.load_file(full_path)
    end
  end
end
