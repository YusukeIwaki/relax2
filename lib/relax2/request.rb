# frozen_string_literal: true

module Relax2
  # Stores abstract request intents for building Net::HTTP::Request
  Request = Struct.new(:http_method, :path, :query_parameters, :headers, :body, keyword_init: true) do
    # @param args [Array<String>] assumed to be CLI args. ['GET', '/hoge', 'Authorization:', 'Bearer' 'mytopsecret']
    # @param body [String|nil] assumed to be CLI PIPE input.
    def self.from(args:, body: nil)
      arg = FluentArg.new(args)

      raise InvalidArgError, 'STDIN is not acceptable when @body is specified' if arg.magic_parameters[:body] && body

      body = arg.magic_parameters[:body] ? IO.read(arg.magic_parameters[:body]) : body

      new(
        http_method: arg.http_method,
        path: arg.path,
        query_parameters: arg.query_parameters,
        headers: arg.headers,
        body: body,
      )
    end

    def initialize(...)
      super
      freeze
    end
  end
  Request::SUPPORTED_METHODS = %w[GET POST PUT PATCH DELETE].freeze
end
