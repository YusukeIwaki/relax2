# frozen_string_literal: true

require 'net/http'

module Relax2
  class RequestContext
    def initialize(base_url:, interceptors:)
      raise InvalidArgError, 'base_url must be specified' unless base_url

      @base_url = base_url
      @interceptors = interceptors
    end

    # @param request [Relax2::Request]
    # @return [Relax2::Response]
    def call(request)
      original_method = ActualHttpRequestHandler.new(@base_url)
      call_with_interceptors = @interceptors.reduce(original_method) do |m, interceptor|
        ->(req) { interceptor.call(req, m) }
      end
      call_with_interceptors.call(request)
    end

    NET_HTTP_REQUEST_MAP = {
      'GET' => Net::HTTP::Get,
      'POST' => Net::HTTP::Post,
      'PUT' => Net::HTTP::Put,
      'PATCH' => Net::HTTP::Patch,
      'DELETE' => Net::HTTP::Delete
    }.freeze

    class ActualHttpRequestHandler
      def initialize(base_url)
        @base_url = base_url
      end

      # @param [Relax::Request]
      # @return [Relas2::Response]
      def call(request)
        net_http_request = net_http_request_from(request)
        net_http_response = start_net_http_session do |http|
          http.request(net_http_request)
        end
        response_from(net_http_response)
      end

      private def start_net_http_session(&block)
        uri = URI.parse(@base_url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', &block)
      end

      private def request_uri_from(request)
        queries = request.query_parameters.map do |param|
          [param.name, param.value]
        end

        URI.parse("#{@base_url}#{request.path}").tap do |uri|
          uri.query = URI.encode_www_form(queries) unless queries.empty?
        end
      end

      private def net_http_request_from(request)
        net_http_request = NET_HTTP_REQUEST_MAP[request.http_method].new(request_uri_from(request))

        request.headers.each do |header|
          net_http_request[header.name] = header.value
        end
        net_http_request.body = request.body if request.body
        net_http_request
      end

      private def response_from(net_http_response)
        headers = []
        net_http_response.each_header do |name, value|
          headers << NameValuePair.new(name, value)
        end

        Response.new(
          status: net_http_response.code.to_i,
          headers: headers,
          body: net_http_response.body,
        )
      end
    end
  end
end
