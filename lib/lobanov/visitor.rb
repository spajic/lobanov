# frozen_string_literal: true

module Lobanov
  class Visitor
    def self.visit(schema)
      Enumerator.new do |visitor|
        go(schema, [], visitor)
      end
    end

    # path is array of string keys
    def self.go(schema, path, visitor)
      current_position = (path == [] ? schema : schema.dig(*path))

      if current_position['type'] == 'object'
        props_path = path + ['properties']
        schema.dig(*props_path).each do |prop_name, prop_value|
          go(schema, props_path + [prop_name], visitor)
        end
        if schema.dig(*props_path) == {} # все пропсы удалили, или не было
          visitor << {path: props_path, value: {}}
        end
      elsif current_position['type'] == 'array' && current_position['items']
        go(schema, path + ['items'], visitor)
      else
        visitor << {path: path, value: current_position}
      end
    end
  end
end
