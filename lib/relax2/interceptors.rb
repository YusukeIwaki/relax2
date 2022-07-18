module Relax2
  module Interceptors
    class PrintRequest
      def initialize(print_headers:, print_body:)
        @print_headers = print_headers
        @print_body = print_body
      end

      def call(request, perform_request)
        lines = []
        lines << "#{request.http_method} #{request.path}"
        if @print_headers
          request.headers.each do |header|
            lines << "#{header.name}: #{header.value}"
          end
        end

        if @print_body && request.body
          lines << ''
          lines << request.body
        end

        puts lines.join("\n")
        puts ''

        perform_request.call(request)
      end
    end

    class PrintResponse
      def initialize(print_status:, print_headers:)
        @print_status = print_status
        @print_headers = print_headers
      end

      def call(request, perform_request)
        lines = []
        response = perform_request.call(request)

        if @print_status
          lines << "HTTP #{response.status}"
        end

        if @print_headers
          response.headers.each do |header|
            lines << "#{header.name}: #{header.value}"
          end
        end

        if response.body
          unless lines.empty?
            lines << ''
          end
          lines << response.body
        end
        puts lines.join("\n")
      end
    end

    module_function def verbose_print_request
      PrintRequest.new(print_headers: true, print_body: true)
    end

    module_function def print_response
      PrintResponse.new(print_status: false, print_headers: false)
    end

    module_function def verbose_print_response
      PrintResponse.new(print_status: true, print_headers: true)
    end

    module_function def json_request
      lambda do |request, perform_request|
        request.headers << ::Relax2::NameValuePair.new('Accept', 'application/json')
        request.headers << ::Relax2::NameValuePair.new('Content-Type', 'application/json')
        perform_request.call(request)
      end
    end
  end
end
