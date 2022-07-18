# frozen_string_literal: true

require 'relax2/dsl'
require 'relax2/errors'
require 'relax2/file_cache'
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
      from_pipe = File.pipe?($stdin)
      from_redirect = !IO.select([$stdin], [], [], 0).nil?
      body = $stdin.read if from_pipe || from_redirect

      request = Request.from(args: ARGV, body: body)

      @interceptors ||= []
      @interceptors << Interceptors.print_response if @interceptors.empty?

      call(request)
    end
  end
end
