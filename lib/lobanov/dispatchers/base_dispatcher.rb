# frozen_string_literal: true

module Lobanov
  module Dispatchers
    class BaseDispatcher
      attr_reader :path_info

      def initialize(request)
        @request = request
        @path_info = request.path_info
      end

      def remove_ignored_namespaces(path)
        res = path
        res.gsub!(api_marker, '')
        res.gsub('//', '/')
      end

      def api_marker
        return @marker if defined? @marker

        @marker = ''
        Lobanov.namespaces.each_key do |key|
          if @path_info.match?(/^\/#{key}/)
            @marker = key
            break
          end
        end

        @marker
      end
    end
  end
end
