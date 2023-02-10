# frozen_string_literal: true

module Lobanov
  module Support
    class ExpandRefs
      def self.call(schema)
        Lobanov::Visitor.visit(schema).each do |node|
          path = node[:path]
          value = node[:value]

          ref = value['$ref']
          next unless ref 

          result = schema.clone
          if ref.start_with?('#')
            raise LobanovError, "Reference to internal schema is not supported yet: #{ref}"
          else
            ref_schema = Support.read_relative(ref)
            expanded_ref_schema = self.call(ref_schema)
            result.dig(*path[0..-2])[path.last] = expanded_ref_schema 
          end
          
          result
        end
      end
    end
  end
end
