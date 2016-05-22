require 'test_helper'

class TheChat::MessageTest < Minitest::Test
  def author
    @author ||=
      begin
        author = TheChat::User.new 'name' => 'name'
        author.password = 'name'
        author.save
        author
      end
  end

  def recipient
    @recipient ||=
      begin
        recipient = TheChat::User.new 'name' => 'recipient'
        recipient.password = 'recipient'
        recipient.save
        recipient
      end
  end

  def test_doesnt_save_without_body
    msg = TheChat::Message.new(
      'body' => nil,
      'author_id' => author.id,
      'recipient_id' => recipient.id
    )
    refute_predicate msg, :persisted?
  end

  def test_doesnt_save_without_author_id
    msg = TheChat::Message.new(
      'body' => 'message!',
      'author_id' => nil,
      'recipient_id' => recipient.id
    )
    refute_predicate msg, :persisted?
  end

  def test_doesnt_save_without_recipient_id
    msg = TheChat::Message.new(
      'body' => 'message!',
      'author_id' => author.id,
      'recipient_id' => nil
    )
    refute_predicate msg, :persisted?
  end

  def test_persistence
    time = Time.now

    Time.stub(:now, time) do
      msg = TheChat::Message.new(
        'body' => 'message!',
        'author_id' => author.id,
        'recipient_id' => recipient.id
      )
      msg.save
      assert_predicate msg, :persisted?

      assert_equal Time.now.to_s, msg.created_at.to_s
    end
  end

  def test_author
    msg = TheChat::Message.new(
      'body' => 'message!',
      'author_id' => author.id,
      'recipient_id' => recipient.id
    )
    msg.save

    assert_equal author, msg.author
    assert_equal recipient, msg.recipient
  end

  def test_read
    msg = TheChat::Message.new(
      'body' => 'message!',
      'author_id' => author.id,
      'recipient_id' => recipient.id
    )

    refute_predicate msg, :read?
    msg.mark_as_read
    assert_predicate msg, :read?
  end

  def test_unread
    msgs = 4.times.map do
      msg = TheChat::Message.new(
        'body' => 'message!',
        'author_id' => author.id,
        'recipient_id' => recipient.id
      )
      msg.save
      msg
    end

    assert_equal msgs, TheChat::Message.unread
  end

  def test_unread_with_recipient
    msgs = 4.times.map do |i|
      msg = TheChat::Message.new(
        'body' => 'message!',
        'author_id' => author.id,
        'recipient_id' => i%2==0 ? author.id : recipient.id
      )
      msg.save
      msg
    end

    assert_equal [msgs[0], msgs[2]], TheChat::Message.unread(author.id)
  end

  def test_as_json
    time = Time.now
    attrs = {
      'body' => 'message',
      'author_id' => author.id,
      'recipient_id' => recipient.id
    }
    msg = TheChat::Message.new(attrs)
    Time.stub(:now, time) { msg.save }
    assert_equal attrs.merge(
      'created_at' => time,
      'read' => false,
      'id' => msg.id
    ), msg.as_json
  end
end
