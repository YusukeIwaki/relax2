require 'net/http'

module Relax2
  class RequestContext
    def initialize(base_url:, interceptors:)
      unless base_url
        raise InvalidArgError, 'base_url must be specified'
      end

      @base_url = base_url
      @interceptors = interceptors
    end

    # @param request [Relax2::Request]
    # @return [Relax2::Response]
    def call(request)
      original_method = method(:perform_actual_http_request)
      call_with_interceptors = @interceptors.reduce(original_method) do |m, interceptor|
        -> (request) { interceptor.call(request, m) }
      end
      call_with_interceptors.call(request)
    end

    NET_HTTP_REQUEST_MAP = {
      'GET' => Net::HTTP::Get,
      'POST' => Net::HTTP::Post,
      'PUT' => Net::HTTP::Put,
      'PATCH' => Net::HTTP::Patch,
      'DELETE' => Net::HTTP::Delete,
    }.freeze

    # @param request [Relax2::Request]
    # @return [Relas2::Response]
    private def perform_actual_http_request(request)
      request_uri = URI.parse("#{@base_url}#{request.path}")
      unless request.query_parameters.empty?
        request_uri.query = URI.encode_www_form(request.query_parameters.map { |param| [param.name, param.value] })
      end

      net_http_request = NET_HTTP_REQUEST_MAP[request.http_method].new(request_uri)
      request.headers.each do |header|
        net_http_request[header.name] = header.value
      end
      if request.body
        net_http_request.body = request.body
      end

      net_http_response = Net::HTTP.start(request_uri.host, request_uri.port, use_ssl: request_uri.scheme == 'https') do |http|
        http.request(net_http_request)
      end

      headers = []
      net_http_response.each_header do |name, value|
        headers << NameValuePair.new(name, value)
      end

      Response.new(
        status: net_http_response.code,
        headers: headers,
        body: net_http_response.body,
      )
    end
  end
end
