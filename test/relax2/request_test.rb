require 'minitest/autorun'
require 'relax2/base'
require 'tempfile'

module Relax2
  class RequestTest < Minitest::Test
    def test_parse_url_simple
      request = Relax2::Request.from(args: 'GET /current_user'.split(' '))
      assert_equal 'GET', request.http_method
      assert_equal '/current_user', request.path
      assert_empty request.headers
      assert_empty request.query_parameters
      assert_nil request.body
    end

    def test_parse_url_with_query_parameters
      request = Relax2::Request.from(args: 'GET /search?q=%E6%97%A5%E6%9C%AC%E8%AA%9E&page=12'.split(' '))
      assert_equal 'GET', request.http_method
      assert_equal '/search', request.path
      assert_empty request.headers
      assert_equal 2, request.query_parameters.size
      assert_nil request.body

      expected = [
        NameValuePair.new('page', '12'),
        NameValuePair.new('q', '日本語'),
      ]
      assert_equal expected, request.query_parameters.sort_by(&:name)
    end

    def test_parse_additional_query_parameters
      request = Relax2::Request.from(args: 'GET /search q=日本語 English'.split(' '))
      assert_equal 'GET', request.http_method
      assert_equal '/search', request.path
      assert_empty request.headers
      assert_equal 1, request.query_parameters.size
      assert_nil request.body

      assert_equal NameValuePair.new('q', '日本語 English'), request.query_parameters.first
    end

    def test_parse_additional_headers
      request = Relax2::Request.from(args: 'GET /current_user Authorization: Bearer xxxxxxxxx X-CUSTOM-ID:Custom 1 2 3'.split(' '))
      assert_equal 'GET', request.http_method
      assert_equal '/current_user', request.path
      assert_equal 2, request.headers.size
      assert_empty request.query_parameters
      assert_nil request.body

      expected_headers = [
        NameValuePair.new('Authorization', 'Bearer xxxxxxxxx'),
        NameValuePair.new('X-CUSTOM-ID', 'Custom 1 2 3')
      ]
      assert_equal expected_headers, request.headers.sort_by(&:name)
    end

    def test_parse_magic_parameter
      request = Tempfile.create('data.json') do |file|
        IO.write(file.path, '{}')
        Relax2::Request.from(args: "PUT /current_user @body=#{file.path}".split(' '))
      end
      assert_equal 'PUT', request.http_method
      assert_equal '/current_user', request.path
      assert_empty request.headers
      assert_empty request.query_parameters
      assert_equal '{}', request.body
    end

    def test_raise_on_nonexist_magic_parameter
      err = assert_raises {
        Relax2::Request.from(args: "PUT /current_user @body=hoge hoge.json".split(' '))
      }
      assert err.is_a?(Errno::ENOENT)
      assert_includes err.message, 'hoge hoge.json'
    end

    def test_raises_on_invalid_magic_parameter
      err = assert_raises {
        Relax2::Request.from(args: 'POST /pets @arg=1'.split(' '))
      }
      assert_includes err.message, 'Unknown parameter: @arg'
    end
  end
end
