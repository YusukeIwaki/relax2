require 'uri'

module Relax2
  # @internal
  class FluentArg
    # @param args [Array<String>] ['GET', '/search', 'q=dart', 'Authorization:' 'Basic' 'aXdha2k6MTIzNDUK']
    def initialize(args)
      @http_method = validated_http_method_for(args)
      path_with_query = validated_path_for(args)
      params_and_headers = parse_params_and_headers_from(args)

      # Merge query parameters
      uri = URI.parse(path_with_query)
      @query_parameters = URI.decode_www_form(uri.query || '').map do |name, value|
        NameValuePair.new(name, value)
      end + params_and_headers.query_parameters
      @path = uri.path

      @headers = params_and_headers.headers

      # Extract @body
      magic_parameters = {}
      params_and_headers.magic_parameters.each do |param|
        if param.name == '@body'
          magic_parameters[:body] = param.value
        else
          raise InvalidArgError, "Unknown parameter: #{param.name}"
        end
      end
      @magic_parameters = magic_parameters
    end

    attr_reader :http_method, :path, :query_parameters, :headers, :magic_parameters

    private def validated_http_method_for(args)
      (Request::SUPPORTED_METHODS & args.first(1)).first or raise InvalidArgError, "HTTP method (GET, POST, ...) must be specified"
    end

    private def validated_path_for(args)
      path = args[1] or raise InvalidArgError, 'path must be specified'
    end

    PARAM_REGEXP = /^(@?[a-zA-Z_]+)=/
    HEADER_REGEXP = /^([a-zA-Z_-]+):/

    ParseResult = Struct.new(:query_parameters, :magic_parameters, :headers) do
      def initialize(...) ; super ; freeze ; end
    end

    private def parse_params_and_headers_from(args)
      query_parameters = []
      magic_parameters = []
      headers = []
      cur = nil

      args[2..]&.each do |arg|
        if param_match = PARAM_REGEXP.match(arg)
          name = param_match[1]
          value = arg[param_match.end(0)..]

          if name.start_with?('@')
            cur = magic_parameters
          else
            cur = query_parameters
          end

          cur << NameValuePair.new(name, value)
          next
        end

        if header_match = HEADER_REGEXP.match(arg)
          name = header_match[1]
          value = arg[header_match.end(0)..]

          cur = headers
          cur << NameValuePair.new(name, value)
          next
        end

        last = cur&.pop or raise InvalidArgError, "Unable to parse args: #{args.join(' ')}"
        if last.value.length > 0
          cur << NameValuePair.new(last.name, "#{last.value} #{arg}")
        else
          cur << NameValuePair.new(last.name, arg)
        end
      end

      ParseResult.new(query_parameters, magic_parameters, headers)
    end
  end
end
