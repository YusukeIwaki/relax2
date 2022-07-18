require 'minitest/autorun'
require 'relax2/base'
require 'rack/test_server'
require 'sinatra/base'

class TestWithRackServer < Minitest::Test
  class TestApp < Sinatra::Base
    get '/200' do
      status(200)
      body('It works!')
    end
    get '/204' do
      status(204)
    end
  end

  def setup
    server_port = (8001..8009).to_a.sample
    @server = Rack::TestServer.new(app: TestApp, Host: '127.0.0.1', Port: server_port)
    @server.start_async
    @server.wait_for_ready
    @base_url = "http://127.0.0.1:#{server_port}"
  end

  def teardown
    @server.stop_async
    @server.wait_for_stopped
  end
end
