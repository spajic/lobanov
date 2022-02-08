# frozen_string_literal: true

module Lobanov
  # wapi/grid_bots -> wapi/GridBots
  # wapi/grid_bots/:id -> wapi/GridBot
  # wapi/owners/:owner_id/pets/:pet_id -> wapi/Pet
  #
  # if 'wapi' is in Lobanov.namespaces_to_ignore
  # wapi/grid_bots -> GridBots
  # wapi/grid_bots/:id -> GridBot
  # wapi/owners/:owner_id/pets/:pet_id -> Pet
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

      ([namespace, component] - [""]).join('/')
    end

    private

    def id?(part)
      part&.start_with?(':')
    end

    def ends_with_id?
      id?(last_part)
    end

    def single_resource_name
      Support.camelize(Support.singularize(parts[-2]))
    end

    def componentize_last_part
      Support.camelize(last_part)
    end

    def last_part
      parts.last
    end

    def namespace
      parts.reject { |part| id?(part) }.join('/')
    end

    def parts
      @parts ||= endpoint_path.split('/').reject(&:empty?) - Lobanov.namespaces_to_ignore
    end
  end
end
