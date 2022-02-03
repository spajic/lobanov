# frozen_string_literal: true

module Lobanov
  # wapi/grid_bots -> wapi/GridBots
  # wapi/grid_bots/:id -> wapi/GridBot
  # wapi/owners/:owner_id/pets/:pet_id -> wapi/Pet
  class ComponentNameByPath
    def self.call(endpoint_path)
      new(endpoint_path).call
    end

    attr_reader :endpoint_path

    def initialize(endpoint_path)
      @endpoint_path = endpoint_path
    end

    def call
      component =
        if ends_with_id?
          single_resource_name
        else
          componentize_last_part
        end

      "#{namespace}/#{component}"
    end

    private

    def id?(part)
      part&.start_with?(':')
    end

    def ends_with_id?
      id?(last_part)
    end

    def single_resource_name
      parts[-2].singularize.camelize
    end

    def componentize_last_part
      last_part.camelize
    end

    def last_part
      parts.last
    end

    def namespace
      res = []
      parts.each_slice(3) do |part|
        if !id?(part[0]) && !id?(part[1]) && (id?(part[2]) || part[2].nil?)
          res << part[0]
        end
      end

      res.join('/')
    end

    def parts
      @parts ||= endpoint_path.split('/').reject(&:blank?)
    end
  end
end
