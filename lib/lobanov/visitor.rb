# frozen_string_literal: true

module Lobanov
  class Visitor
    def self.visit(schema)
      new.visit(schema)
    end

    def visit(schema)
      Enumerator.new do |visitor|
        go(schema, [], visitor)
      end
    end

    private

    # path is array of string keys
    def go(schema, path, visitor)
      current_position = (path == [] ? schema : schema.dig(*path))

      if object?(current_position)
        go_object_branch(schema, path, visitor)
      elsif array?(current_position)
        visitor << { path: path, value: current_position }
        go(schema, path + ['items'], visitor)
      else
        visitor << { path: path, value: current_position }
      end
    end

    def object?(current_position)
      return false unless current_position

      current_position['type'] == 'object'
    end

    def array?(current_position)
      return false unless current_position

      current_position['type'] == 'array' && current_position['items']
    end

    def go_object_branch(schema, path, visitor)
      props_path = path + ['properties']
      schema.dig(*props_path).each do |prop_name, _prop_value|
        go(schema, props_path + [prop_name], visitor)
      end
      visitor << { path: props_path, value: {} } if schema.dig(*props_path) == {} # все пропсы удалили, или не было
    end
  end
end
