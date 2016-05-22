$: << File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'the-chat'
require 'faker'
require 'minitest/autorun'

TheChat::Model.adapter = TheChat::DatabaseAdapter::Memory.new
