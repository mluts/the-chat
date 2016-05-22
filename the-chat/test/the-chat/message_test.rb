require 'test_helper'

class TheChat::MessageTest < Minitest::Test
  def user
    @user ||=
      begin
        user = TheChat::User.new 'name' => 'name'
        user.password = 'name'
        user.save
        user
      end
  end

  def test_doesnt_save_without_body
    msg = TheChat::Message.new(
      'body' => nil,
      'user_id' => user.id
    )
    refute_predicate msg, :persisted?
  end

  def test_doesnt_save_without_user_id
    msg = TheChat::Message.new(
      'body' => 'message!',
      'user_id' => nil
    )
    refute_predicate msg, :persisted?
  end

  def test_persistence
    time = Time.now

    msg = TheChat::Message.new(
      'body' => 'message!',
      'user_id' => user.id
    )
    msg.save
    assert_predicate msg, :persisted?

    Time.stub(:now, time) do
      assert_equal Time.now.to_s, msg.created_at.to_s
    end
  end
end
