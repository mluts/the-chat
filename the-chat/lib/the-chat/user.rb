require 'the-chat/model'
require 'bcrypt'

module TheChat
  class User < Model
    include BCrypt

    def_attr :name,
             :encrypted_password,
             :admin,
             :about

    def admin?
      !!admin
    end

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
      self.encrypted_password = Password.create(password) if password
      self.password = nil

      return if !persisted? && self.class.first('name' => name)

      if encrypted_password && name
        super
      end
    end

    def as_json
      super.tap { |hash| hash.delete 'encrypted_password' }
    end
  end
end
