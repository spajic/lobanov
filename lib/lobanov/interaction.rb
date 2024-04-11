# frozen_string_literal: true

module Lobanov
  # Interaction represents request-response interaction
  class Interaction
    PREFIX = 'action_dispatch.request'

    attr_reader(
      :verb,
      :api_marker,
      :endpoint_path,
      :controller_action,
      :path_info,
      :path_params,
      :query_params,
      :payload,
      :status,
      :body
    )

    def initialize(**params)
      @verb = params[:verb]
      @api_marker = params[:api_marker]
      @endpoint_path = params[:endpoint_path]
      @controller_action = params[:controller_action]
      @path_info = params[:path_info]
      @path_params = params[:path_params]
      @query_params = params[:query_params]
      @payload = params[:payload]

      @status = params[:status]
      @body = params[:body]
    end

    def operation_id
      GenerateOperationId.call(self)
    end

    def path_with_square_braces
      @path_with_square_braces ||= GeneratePathWithSquareBraces.call(self)
    end

    def path_with_curly_braces
      if path_with_square_braces == '/'
        "/#{api_marker}/#{path_info.gsub('[', '{').gsub(']', '}')}".gsub('//', '/')
      else
        "/#{api_marker}/#{path_with_square_braces.gsub('[', '{').gsub(']', '}')}".gsub('//', '/')
      end
    end

    def base_path
      path = "#{Lobanov.specification_folder}/#{Lobanov.namespaces[api_marker]}"
      Pathname.new(path)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.from_action_dispatch(request, response)
      json_body =
        begin
          JSON.parse(response.body)
        rescue StandardError => _e
          error_message =
            'Lobanov requires response.body to be parsable JSON, ' \
            "but got '#{response.body}'"
          raise error_message
        end

      dispatcher = Lobanov.dispatcher.new(request)

      params = {
        verb: dispatcher.method,
        api_marker: dispatcher.api_marker,
        endpoint_path: dispatcher.remove_ignored_namespaces(dispatcher.route_name),
        controller_action: dispatcher.controller_action,
        path_info: dispatcher.remove_ignored_namespaces(dispatcher.path_info),
        path_params: dispatcher.path_params,
        query_params: dispatcher.query_params,
        payload: dispatcher.payload,
        status: response.status,
        body: json_body
      }

      new(**params)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
