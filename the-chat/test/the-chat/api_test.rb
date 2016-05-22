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
    user = TheChat::User.new('name' => username)
    user.password = pass
    user.save

    other_names.each do |name|
      user = TheChat::User.new('name' => name)
      user.password = name
      user.save
    end
  end

  def test_unauthorized_by_default
    get '/me/info' do |response|
      assert_predicate response, :unauthorized?
    end
  end

  def test_me
    basic_authorize username, pass

    get '/me/info' do |response|
      assert_predicate response, :ok?
      assert_equal username, response.json['name']
    end
  end

  def test_all_users
    basic_authorize username, pass

    get '/me/all' do |response|
      assert_equal other_names.count + 1, response.json.count
    end
  end

  def test_register
    name = 'juke'
    assert_nil TheChat::User.first('name' => name)
    post '/register', name: name, password: name do |response|
      assert_predicate response, :created?
      refute_nil TheChat::User.first('name' => name)
    end
  end

  def test_register_with_wrong_params
    name = 'juke'
    assert_nil TheChat::User.first('name' => name)
    post '/register', name: name, password: nil do |response|
      refute_predicate response, :created?
      assert_nil TheChat::User.first('name' => name)
    end
  end
end
