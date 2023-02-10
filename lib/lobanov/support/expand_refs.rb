# frozen_string_literal: true

module Lobanov
  module Support
    class ExpandRefs
      def self.call(schema, index_folder)
        Lobanov::RefVisitor.visit(schema).each do |node|
          path = node[:path]
          value = node[:value]

          ref = value['$ref']

          if ref.start_with?('#')
            raise LobanovError, "Reference to internal schema is not supported yet: #{ref}"
          else
            ref_schema = Support.read_relative_from_path(ref, index_folder)
            expanded_ref_schema = self.call(ref_schema, index_folder) # recursion here
            if expanded_ref_schema == ref_schema
              # nothing to do
            elsif path == [] # expanded schema contains only the ref and nothing else
              schema = expanded_ref_schema
            else
              schema.dig(*path[0..-2])[path.last] = expanded_ref_schema 
            end
          end
        end

        schema
      end
    end
  end
end
