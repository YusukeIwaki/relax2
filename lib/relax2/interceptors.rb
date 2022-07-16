module Relax2
  module Interceptors
    class PrintRequest
      def initialize(print_headers: true, print_body: true)
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
      def initialize(print_status: true, print_headers: true)
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
  end
end
