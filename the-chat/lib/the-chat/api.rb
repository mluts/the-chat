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

      get :unread do
        Message.unread(current_user.id).map(&:as_json)
      end

      get :messages do
        Message.select('recipient_id' => current_user.id).map(&:as_json)
      end

      params do
        requires :recipient, type: String
        requires :body, type: String
      end
      post :send_message do
        user = User.first(name: params[:recipient])
        if user.nil?
          status :not_found
          {
            error: "User #{params[:recipient].inspect} doesn't exist"
          }
        else
          message = Message.new(
            'body'          => params[:body],
            'author_id'     => current_user.id,
            'recipient_id'  => user.id
          )
          message.save
          status :created
          {status: 'ok'}
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
        status :created
        { status: 'ok' }
      else
        status :bad_request
        { error: "Username #{user.name.inspect} has already been taken" }
      end
    end
  end
end
