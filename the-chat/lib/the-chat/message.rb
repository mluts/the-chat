module TheChat
  class Message < Model
    def_attr :body,
             :author_id,
             :recipient_id,
             :read,
             :created_at

    class << self
      def unread(recipient = nil)
        query = { 'read' => nil }
        query['recipient_id'] = recipient if recipient
        select(query)
      end
    end

    def author
      User.find(author_id)
    end

    def recipient
      User.find(recipient_id)
    end

    def read?
      read
    end

    def mark_as_read
      self.read = true
      save
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
