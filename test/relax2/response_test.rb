# frozen_string_literal: true

require_relative '../test_helper'

module Relax2
  class ResponseTest < TestWithRackServer
    def setup
      super
      @context = RequestContext.new(base_url: @base_url, interceptors: [])
    end

    def test_status_code
      response = @context.call(Request.from(args: 'GET /200'.split(' ')))
      assert_equal 200, response.status
      response = @context.call(Request.from(args: 'GET /204'.split(' ')))
      assert_equal 204, response.status
    end

    def test_body
      response = @context.call(Request.from(args: 'GET /200'.split(' ')))
      assert_equal 'It works!', response.body
      response = @context.call(Request.from(args: 'GET /204'.split(' ')))
      assert_nil response.body
    end
  end
end
