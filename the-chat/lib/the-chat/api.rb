require 'grape'

module TheChat
  class API < Grape::API
    version 'v1', using: :header, vendor: 'the-chat'
    format :json

    class << self
      def env
        ENV['RACK_ENV'] ||= 'development'
      end
    end

    helpers do
      def current_user
        @current_user ||= User.first(name: auth.username)
      end

      def auth
        @auth ||= Rack::Auth::Basic::Request.new(env)
      end
    end

    http_basic do |username, password|
      User.authorized?(username, password)
    end

    get :me do
      { name: current_user.name }
    end
  end
end
