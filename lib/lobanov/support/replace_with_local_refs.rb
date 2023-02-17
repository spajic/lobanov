# frozen_string_literal: true

#module Lobanov
#  module Support
#    # TODO: rename to ReplaceRefsWithRegisteredComponents
#    class ReplaceWithLocalRefs
#      attr_reader :schema
#      attr_reader :registered_components
#      
#      def self.call(schema:)
#        new(schema: schema.call)
#      end
#      
#      def initialize(schema:)
#        @schema = schema
#        @registered_components = {}
#      end
#      
#      def call
#        build_registered_components 
#        replace_refs
#      end
#
#      private
#
#      def replace_refs
#        Lobanov::RefVisitor.visit(schema).each do |node|
#          path = node[:path]
#          value = node[:value]
#          ref = value['$ref']
#          if registered_components.key?(ref)
#            binding.pry
#            schema.dig(*path) = registered_components[ref]
#          end
#        end
#        schema
#      end
#    end
#  end
#end
#
