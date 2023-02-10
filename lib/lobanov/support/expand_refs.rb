# frozen_string_literal: true

module Lobanov
  module Support
    class ExpandRefs
      def self.call(schema, index_folder)
        recursion = true
        Lobanov::RefVisitor.visit(schema).each do |node|
          path = node[:path]
          value = node[:value]
          puts "✅"
          puts path.join('->')
          puts value

          ref = value['$ref']

          if ref.start_with?('#')
            raise LobanovError, "Reference to internal schema is not supported yet: #{ref}"
          else
            ref_schema = Support.read_relative_from_path(ref, index_folder)
            expanded_ref_schema = self.call(ref_schema, index_folder) # recursion here
            if path == [] 
              schema = expanded_ref_schema
            else
              schema.dig(*path[0..-2])[path.last] = expanded_ref_schema 
            end
          end
        end

        schema
#      rescue StandardError => e
#        binding.pry
      end
    end
  end
end
