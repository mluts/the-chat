require 'test_helper'

class TheChat::UserTest < Minitest::Test
  def test_cant_save_without_name
    user = TheChat::User.new
    user.password = 'the-password'
    user.save
    refute_predicate user, :persisted?
  end

  def test_cant_save_without_password
    user = TheChat::User.new
    user.name = 'name'
    user.save
    refute_predicate user, :persisted?
  end

  def test_cant_save_with_same_name
    attrs = { 'name' => 'name', }

    user = TheChat::User.new(attrs)
    user.password = 'pass'
    user.save

    user2 = TheChat::User.new(attrs)
    user2.password = 'pass'
    user2.save

    assert_predicate user, :persisted?
    refute_predicate user2, :persisted?
  end

  def test_valid_password
    user = TheChat::User.new
    user.name = 'name'
    user.password = 'pass'
    user.save

    assert_predicate user, :persisted?

    user = TheChat::User.find(user.id)
    refute_predicate user, :valid_password?
    user.password = 'pass'
    assert_predicate user, :valid_password?
  end

  def test_authorized
    user = TheChat::User.new('name' => 'name')
    user.password = 'pass'
    user.save
    assert TheChat::User.authorized?('name', 'pass')
    refute TheChat::User.authorized?('name', 'passd')
    refute TheChat::User.authorized?('named', 'pass')
  end

  def test_admin
    user = TheChat::User.new('name' => 'name')
    user.password = 'pass'
    refute_predicate user, :admin?
    user.admin = true
    user.save
    assert_predicate TheChat::User.first('admin' => true),
                     :admin?
  end

  def test_as_json
    user = TheChat::User.new 'name' => 'name', 'about' => 'about'
    user.password = 'pass'
    user.save
    assert_equal({
      'name' => 'name',
      'about' => 'about'
    }, user.as_json)
  end
end
