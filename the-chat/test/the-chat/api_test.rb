require 'test_helper'

class TheChat::APITest < ApiTest
  def username
    @name ||= Faker::Lorem.word
  end

  def pass
    @pass ||= Faker::Lorem.word
  end

  def setup
    user = TheChat::User.new('name' => username)
    user.password = pass
    user.save
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
end
