# frozen_string_literal: true

module Lobanov
  module Dispatchers
    class GrapeDispatcher < BaseDispatcher
      PREFIX = 'grape'

      attr_reader :prefix

      def initialize(...)
        super(...)
        @prefix = PREFIX
      end

      def method
        @request.env['REQUEST_METHOD']
      end

      def controller_action
        @request.env["#{PREFIX}.routing_args"][:route_info].translator.attributes.dig(:settings, :action)
      end

      def route_name
        route = @request.env["#{PREFIX}.routing_args"][:route_info].pattern.path.to_s.sub('(.:format)', '')
        return route if route.present?

        message = "Cannot find named route for: #{@request.env['HTTP_HOST']}#{@request.path_info}"
        raise NonroutableRequestError, message
      end

      def path_params
        @request.env['rack.request.query_hash'].stringify_keys.except('format')
      end

      def query_params
        @query_params ||= @request.env['rack.request.query_hash']
      end

      def payload
        @request.env['rack.request.form_hash'].merge(
          query_params
        ).stringify_keys.except('action', 'controller', 'format', '_method')
      end
    end
  end
end