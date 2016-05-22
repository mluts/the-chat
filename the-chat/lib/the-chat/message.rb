module TheChat
  class Message < Model
    def_attr :body,
             :author_id,
             :recipient_id,
             :created_at

    def author
      User.find(author_id)
    end

    def recipient
      User.find(recipient_id)
    end

    def save
      self.created_at ||= Time.now

      if body &&
         author_id &&
         recipient_id &&
         created_at
        super
      end
    end
  end
end
