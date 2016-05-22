require 'grape'

module TheChat
  class API < Grape::API
    version 'v1', using: :header, vendor: 'the-chat'
    format :json

    class << self
      def env
        ENV['RACK_ENV'] ||= 'development'
      end

      attr_accessor :auth_enabled
    end

    self.auth_enabled = true

    http_basic do |username, password|
      auth_enabled && User.authorize(username, password)
    end

    get :me do
    end
  end
end
