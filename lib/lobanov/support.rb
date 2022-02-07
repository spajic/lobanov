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
  end
end
