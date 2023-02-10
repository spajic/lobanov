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
            binding.pry
            # expanded_ref_schema = self.call(ref_schema) # recursion here
            # schema.dig(*path[0..-2])[path.last] = expanded_ref_schema 
             schema.dig(*path[0..-2])[path.last] = ref_schema 
          end
        end

        schema
      end
    end
  end
end
