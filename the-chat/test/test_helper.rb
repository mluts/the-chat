$: << File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'the-chat'
require 'faker'
require 'rack/test'
require 'minitest/autorun'
require 'pry'

TheChat::Model.adapter = TheChat::DatabaseAdapter::Memory.new

class Minitest::Test
  def teardown
    TheChat::Model.adapter.reset
  end
end

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TheChat::API
  end
end

class Rack::Response
  def json
    JSON.parse(body)
  end
end
