require 'the-chat/model'
require 'bcrypt'

module TheChat
  class User < Model
    include BCrypt
    def_attr :name, :encrypted_password

    attr_accessor :password

    class << self
      def authorize(name, pass)
        user = first(name: name)
        if user
          user.password = pass
          user.valid_password? && user
        end
      end

      def authorized?(name, pass)
        !!authorize(name, pass)
      end
    end

    def valid_password?
      Password.new(encrypted_password) == password
    end

    def save
      self.encrypted_password ||= Password.create(password) if password

      if encrypted_password && name && !(self.class.first(name: name))
        super
      end
    end
  end
end
