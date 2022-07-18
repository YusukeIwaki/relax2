# frozen_string_literal: true

require_relative '../test_helper'

module Relax2
  class DslTest < TestWithRackServer
    def setup
      super
      ::Relax2::Interceptors.define_singleton_method(:dsl_test) do
        lambda do |request, perform_request|
          response = perform_request.call(request)
          Response.new(status: 200, headers: [], body: "DSL-Test1 #{response.body}")
        end
      end
    end

    def teardown
      super
      ::Relax2::Interceptors.singleton_class.remove_method(:dsl_test)
    end

    def test_interceptor_symbol
      a_base_url = @base_url
      app = Class.new(::Relax2::Base) do
        base_url a_base_url
        interceptor :dsl_test
      end
      response = app.call(Request.from(args: 'GET /200'.split(' ')))
      assert_includes response.body, 'DSL-Test1'
    end

    def test_interceptor_callable
      a_base_url = @base_url
      callable = lambda do |request, perform_request|
        response = perform_request.call(request)
        Response.new(status: 200, headers: [], body: "DSL-Test2 #{response.body}")
      end
      app = Class.new(::Relax2::Base) do
        base_url a_base_url
        interceptor callable
      end
      response = app.call(Request.from(args: 'GET /200'.split(' ')))
      assert_includes response.body, 'DSL-Test2'
    end

    def test_interceptor_block
      a_base_url = @base_url
      app = Class.new(::Relax2::Base) do
        base_url a_base_url
        interceptor do |request, perform_request|
          response = perform_request.call(request)
          Response.new(status: 200, headers: [], body: "DSL-Test3 #{response.body}")
        end
      end
      response = app.call(Request.from(args: 'GET /200'.split(' ')))
      assert_includes response.body, 'DSL-Test3'
    end
  end
end
