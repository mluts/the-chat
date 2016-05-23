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
        error! "User #{params[:recipient].inspect} doesn't exist", :not_found
      elsif user.id == current_user.id
        error! 'Messages to self are not allowed', :bad_request
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

    namespace :admin do
      before do
        unless current_user.admin?
          error! "Route not allowed", :forbidden
        end
      end

      params do
        requires :name, type: String
        requires :body, type: String
      end
      post :create_user do
      end
    end
  end
end
