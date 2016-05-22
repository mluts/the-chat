module TheChat
  class Message < Model
    def_attr :body, :user_id, :created_at

    def user
      User.find(user_id)
    end

    def save
      self.created_at ||= Time.now

      if body && user_id && created_at
        super
      end
    end
  end
end
