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
        elsif api_marker == 'papi'
          'papi'
        else
          version_number = api_marker.last
          "private/v#{version_number}"
        end

      read_relative_from_path(relative_path, "#{Lobanov.specification_folder}/#{api_marker_path}/")
    end

    def self.read_relative_from_path(relative_path, path)
      YAML.load_file("#{path}/#{relative_path}")
    end
  end
end
