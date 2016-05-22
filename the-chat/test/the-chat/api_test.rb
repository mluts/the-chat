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
    get '/me' do |response|
      assert_predicate response, :unauthorized?
    end
  end

  def test_me
    basic_authorize username, pass

    get '/me' do |response|
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
end
