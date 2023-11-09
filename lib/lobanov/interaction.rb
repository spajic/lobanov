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
      path =
        if api_marker == 'wapi'
          "#{Lobanov.specification_folder}/wapi"
        elsif api_marker == 'papi'
          "#{Lobanov.specification_folder}/papi"
        else
          version_number = api_marker.last
          "#{Lobanov.specification_folder}/private/v#{version_number}"
        end
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

      api_marker = api_marker(request.path_info)
      params = {
        verb: request.method,
        api_marker: api_marker,
        endpoint_path: remove_ignored_namespaces(route_name(request), api_marker),
        controller_action: controller_action(request),
        path_info: remove_ignored_namespaces(request.path_info, api_marker),
        path_params: request.env["#{PREFIX}.path_parameters"].stringify_keys.except('format'),
        query_params: request.env["#{PREFIX}.query_parameters"],
        payload: request.env["#{PREFIX}.request_parameters"].merge(
          request.env["#{PREFIX}.query_parameters"]
        ).stringify_keys.except('action', 'controller', 'format', '_method'),
        status: response.status,
        body: json_body
      }

      new(**params)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.remove_ignored_namespaces(path, api_marker)
      res = path
      res.gsub!(api_marker, '')
      res.gsub('//', '/')
    end

    def self.controller_action(request)
      Rails.application.routes.recognize_path(request.url, method: request.method)[:action]
    end

    def self.route_name(request)
      Rails.application.routes.router.recognize(request) do |route, _params|
        return route.path.spec.to_s.sub('(.:format)', '')
      end

      message = "Cannot find named route for: #{request.env['HTTP_HOST']}#{request.path_info}"
      raise NonroutableRequestError, message
    end

    def self.api_marker(path_info)
      splitted_route = path_info.split('/').reject(&:empty?)
      main_marker = splitted_route.first
      case main_marker
      when 'wapi' then 'wapi'
      when 'papi' then 'papi'
      when 'api' then "#{main_marker}/#{splitted_route.second}"
      end
    end
  end
end
