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

    namespace :me do
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

      get :info do
        { name: current_user.name }
      end

      get :all do
        User.all.map do |user|
          {name: user.name}
        end
      end
    end


    params do
      requires :name, type: String
      requires :password, type: String
    end
    post :register do
      user = User.new 'name' => params[:name]
      user.password = params[:password]
      user.save

      if user.persisted?
        status 201
        { status: 'ok' }
      else
        status 400
        { error: "Username #{user.name.inspect} has already been taken" }
      end
    end
  end
end
