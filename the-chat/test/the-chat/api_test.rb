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
    get '/profile' do |response|
      assert_predicate response, :unauthorized?
    end
  end

  def test_profile
    basic_authorize username, pass

    get '/profile' do |response|
      assert_predicate response, :ok?
      assert_equal username, response.json['name']
    end

    name = other_names.sample

    get '/profile', name: name do |response|
      assert_predicate response, :ok?
      assert_equal name, response.json['name']
    end
  end

  def test_all_users
    basic_authorize username, pass

    get '/users' do |response|
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
    get '/messages', unread: true do |response|
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

    post '/messages', recipient: other_user.name, body: 'hello!' do |response|
      assert_predicate response, :created?
      assert_equal 'hello!',
                   TheChat::Message.unread(other_user.id).last.body
    end

    post '/messages', recipient: username, body: 'hello!' do |response|
      assert_predicate response, :bad_request?
    end
  end

  def test_create_user
    new_user_name = 'juke'
    new_user_pass = 'juke'
    basic_authorize username, pass

    post '/admin/users', name: new_user_name, password: new_user_pass do |response|
      assert_predicate response, :forbidden?
      assert_nil TheChat::User.first('name' => new_user_name)
    end

    @user.admin = true
    @user.save

    post '/admin/users', name: new_user_name, password: new_user_pass do |response|
      assert_predicate response, :created?
      refute_nil TheChat::User.first('name' => new_user_name)
    end
  end

  def test_update_info
    basic_authorize username, pass
    assert_nil @user.reload.about
    put '/profile', about: 'about' do |response|
      assert_predicate response, :ok?
      assert_equal 'about', @user.reload.about
    end
  end
end
