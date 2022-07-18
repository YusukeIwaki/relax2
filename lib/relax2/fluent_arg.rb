# frozen_string_literal: true

require 'uri'

module Relax2
  # @internal
  class FluentArg
    # @param args [Array<String>] ['GET', '/search', 'q=dart', 'Authorization:' 'Basic' 'aXdha2k6MTIzNDUK']
    def initialize(args)
      maybe_http_method, maybe_path_with_query, *maybe_args = args
      @http_method = validated_http_method_for(maybe_http_method)
      path_with_query = validated_path_for(maybe_path_with_query)
      params_and_headers = parse_params_and_headers_from(maybe_args)

      # Merge query parameters
      uri = URI.parse(path_with_query)
      @query_parameters = query_parameters_from(uri) + params_and_headers.query_parameters
      @path = uri.path
      @headers = params_and_headers.headers
      @magic_parameters = validated_magic_parameters_from(params_and_headers.magic_parameters)
    end

    attr_reader :http_method, :path, :query_parameters, :headers, :magic_parameters

    private def validated_http_method_for(maybe_http_method)
      raise InvalidArgError, 'HTTP method (GET, POST, ...) must be specified' unless Request::SUPPORTED_METHODS.include?(maybe_http_method)

      maybe_http_method
    end

    private def validated_path_for(maybe_path_with_query)
      maybe_path_with_query or raise InvalidArgError, 'path must be specified'
    end

    # @return [Array<Relax2::NameValuePair>]
    private def query_parameters_from(base_uri)
      URI.decode_www_form(base_uri.query || '').map do |name, value|
        NameValuePair.new(name, value)
      end
    end

    private def validated_magic_parameters_from(magic_parameters)
      # Extract @body
      magic_parameters.each_with_object({}) do |param, result|
        raise InvalidArgError, "Unknown parameter: #{param.name}" unless param.name == '@body'

        result[:body] = param.value
      end
    end

    ParseResult = Struct.new(:query_parameters, :magic_parameters, :headers) do
      def initialize(...)
        super
        freeze
      end
    end

    private def match_parameters(arg)
      if (match = /^(@?[a-zA-Z_]+)=/.match(arg))
        name = match[1]
        value = arg[match.end(0)..]

        yield(name, value)

        true
      else
        false
      end
    end

    private def match_headers(arg)
      if (match = /^([a-zA-Z_-]+):/.match(arg))
        name = match[1]
        value = arg[match.end(0)..]

        yield(name, value)

        true
      else
        false
      end
    end

    # rubocop:disable Style/AbcSize, Metrics/MethodLength
    private def parse_params_and_headers_from(maybe_args)
      query_parameters = []
      magic_parameters = []
      headers = []
      cur = nil

      maybe_args.each do |arg|
        next if match_parameters(arg) do |name, value|
          cur =
            if name.start_with?('@')
              magic_parameters
            else
              query_parameters
            end

          cur << NameValuePair.new(name, value)
        end

        next if match_headers(arg) do |name, value|
          cur = headers
          cur << NameValuePair.new(name, value)
        end

        last = cur&.pop or raise InvalidArgError, "Unable to parse args: #{args.join(' ')}"
        cur << NameValuePair.new(last.name, "#{last.value} #{arg}".lstrip)
      end

      ParseResult.new(query_parameters, magic_parameters, headers)
    end
    # rubocop:enable Style/AbcSize, Metrics/MethodLength
  end
end
