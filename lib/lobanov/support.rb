# frozen_string_literal: true

src = File.expand_path("../support/inflector/*.rb", __FILE__)
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

    def self.read_relative(relative_path)
      full_path = "#{Lobanov.specification_folder}/#{relative_path}"
      YAML.load_file(full_path)
    end
  end
end
