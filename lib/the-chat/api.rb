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

    http_basic realm: 'The-Chat Authentication' do |username, password|
      if User.all.empty?
        user = User.new(
          'name' => username,
          'password' => password,
          'admin' => true
        )
        user.save
      end

      User.authorized?(username, password)
    end

    params do
      optional :name, type: String
    end
    get :profile do
      name = params[:name]
      if name && (user = User.first(name: name))
        user.as_json
      else
        current_user.as_json
      end
    end

    params do
      requires :about, type: String
    end
    put :profile do
      current_user.about = params[:about]
      current_user.save
    end

    get :users do
      User.all.map(&:as_json)
    end

    params do
      optional :unread, type: Boolean
    end
    get :messages do
      query = {
        'recipient_id' => current_user.id
      }
      query['read'] = nil if params[:unread]
      Message.select(query).map(&:as_json)
    end

    params do
      requires :recipient, type: String
      requires :body, type: String
    end
    post :messages do
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
        {status: 'created'}
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
        requires :password, type: String
      end
      post :users do
        name = params[:name]
        pass = params[:password]
        if User.first(name: name)
          error! "Username #{name.inspect} has been taken"
        else
          user = User.new 'name' => name
          user.password = pass
          user.save
          status :created
          {status: 'created'}
        end
      end

      params do
        requires :name, type: String
        optional :new_name, type: String
        optional :password, type: String
        optional :about, type: String
      end
      put :users do
        name = params[:name]
        user = User.first 'name' => name
        if user
          user.name   = params[:new_name] if params[:new_name]
          user.about  = params[:about] if params[:about]
          user.password = params[:password] if params[:password]
          user.save
          status 200
          {status: 'updated'}
        else
          error! "User #{name.inspect} not found", :not_found
        end
      end

      params do
        requires :name, type: String
      end
      delete :users do
        name = params[:name]
        user = User.first 'name' => name
        if user
          user.delete
          status 200
          {status: 'deleted'}
        else
          error! "User #{name.inspect} not found", :not_found
        end
      end
    end
  end
end
