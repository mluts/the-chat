require 'test_helper'

class TheChat::APITest < ApiTest
  def username
    @name ||= Faker::Lorem.word
  end

  def pass
    @pass ||= Faker::Lorem.word
  end

  def other_names
    @other ||= %w(name1 name2 name3 name4)
  end

  def setup
    @user = TheChat::User.new('name' => username)
    @user.password = pass
    @user.save

    other_names.each do |name|
      user = TheChat::User.new('name' => name)
      user.password = name
      user.save
    end
  end

  def test_unauthorized_by_default
    get '/info' do |response|
      assert_predicate response, :unauthorized?
    end
  end

  def test_me
    basic_authorize username, pass

    get '/info' do |response|
      assert_predicate response, :ok?
      assert_equal username, response.json['name']
    end
  end

  def test_all_users
    basic_authorize username, pass

    get '/all' do |response|
      assert_equal other_names.count + 1, response.json.count
    end
  end

  def test_unread
    msgs = 4.times.map do
      msg = TheChat::Message.new(
        'body' => 'msg',
        'recipient_id' => @user.id,
        'author_id' => @user.id
      )
      msg.save
      msg
    end
    msgs[2..-1].each(&:mark_as_read)

    basic_authorize username, pass
    get '/unread' do |response|
      assert_predicate response, :ok?
      assert_equal 2, response.json.count
      assert_equal 'msg', response.json[0]['body']
      assert_equal false, response.json[0]['read']
    end
  end

  def test_messages
    msgs = 4.times.map do |i|
      msg = TheChat::Message.new(
        'body' => "msg",
        'recipient_id' => @user.id,
        'author_id' => @user.id
      )
      msg.save
      msg
    end
    msgs[2..-1].each(&:mark_as_read)

    basic_authorize username, pass
    get '/messages' do |response|
      assert_predicate response, :ok?
      assert_equal 4, response.json.count
      assert_equal 'msg', response.json[0]['body']
      assert_equal false, response.json[0]['read']
      assert_equal true, response.json[2]['read']
    end
  end

  def test_send
    basic_authorize username, pass
    other_user = TheChat::User.all.last
    refute_equal other_user.id, @user.id

    post '/send_message', recipient: other_user.name, body: 'hello!' do |response|
      assert_predicate response, :created?
      assert_equal 'hello!',
                   TheChat::Message.unread(other_user.id).last.body
    end

    post '/send_message', recipient: username, body: 'hello!' do |response|
      assert_predicate response, :bad_request?
    end
  end
end
