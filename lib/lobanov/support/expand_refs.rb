# frozen_string_literal: true

module Lobanov
  module Support
    class ExpandRefs
      def self.call(schema, current_folder)
        current_path = Pathname.new(current_folder)

        Lobanov::RefVisitor.visit(schema).each do |node|
          path = node[:path]
          value = node[:value]

          ref = value['$ref']
          ref_path = current_path.join(ref)
          ref_folder = ref_path.parent

          ref_schema = Support.read_relative_from_path(ref, current_path)
          expanded_ref_schema = self.call(ref_schema, ref_folder) # recursion here
          if path == [] # expanded schema contains only the ref and nothing else
            schema = expanded_ref_schema
          elsif path.size == 1
            schema[path.last] = expanded_ref_schema
          else
            schema.dig(*path[0..-2])[path.last] = expanded_ref_schema 
          end
        end
        
        schema
      end
    end
  end
end
