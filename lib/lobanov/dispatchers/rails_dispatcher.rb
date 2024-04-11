# frozen_string_literal: true

module Lobanov
  module Dispatchers
    class RailsDispatcher < BaseDispatcher
      PREFIX = 'action_dispatch.request'

      attr_reader :prefix

      def self.routes
        @routes ||= Rails.application.routes
      end

      def initialize(...)
        super(...)
        @routes = self.class.routes
      end

      def method
        @method ||= @request.method
      end

      def controller_action
        @routes.recognize_path(@request.url, method: method)[:action]
      end

      def route_name
        @routes.router.recognize(@request) do |route, _params|
          return route.path.spec.to_s.sub('(.:format)', '')
        end

        message = "Cannot find named route for: #{@request.env['HTTP_HOST']}#{@request.path_info}"
        raise NonroutableRequestError, message
      end

      def path_params
        @request.env["#{PREFIX}.path_parameters"].stringify_keys.except('format')
      end

      def query_params
        @query_params ||= @request.env["#{PREFIX}.query_parameters"]
      end

      def payload
        @request.env["#{PREFIX}.request_parameters"].merge(
          query_params
        ).stringify_keys.except('action', 'controller', 'format', '_method')
      end
    end
  end
end
