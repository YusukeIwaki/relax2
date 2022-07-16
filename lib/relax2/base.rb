require 'relax2/dsl'
require 'relax2/errors'
require 'relax2/fluent_arg'
require 'relax2/interceptors'
require 'relax2/name_value_pair'
require 'relax2/request'
require 'relax2/request_context'
require 'relax2/response'

module Relax2
  class Base
    extend DSL

    def self.call(request)
      RequestContext.new(base_url: @base_url, interceptors: @interceptors).call(request)
    end

    def self.run
      from_pipe = File.pipe?(STDIN)
      from_redirect = !IO.select([STDIN], [], [], 0).nil?
      body =
        if from_pipe || from_redirect
          STDIN.read
        else
          nil
        end

      request = Request.from(args: ARGV, body: body)

      @interceptors ||= []
      if @interceptors.empty?
        @interceptors << Interceptors::PrintResponse.new(print_status: false, print_headers: false)
      end

      call(request)
    end
  end
end
