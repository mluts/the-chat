require 'test_helper'

class TheChat::ModelTest < Minitest::Test
  class User < TheChat::Model
    def_attr :name, :password
  end

  def sample_name
    @name ||= Faker::Lorem.word
  end

  def sample_password
    @password ||= Faker::Lorem.word
  end

  def test_it_can_be_saved
    record = User.new
    record.name = sample_name
    record.password = sample_password
    record.save

    assert_equal record, User.find(record.id)
    assert_equal [record], User.select(record.attributes)
    assert_equal record, User.first(record.attributes)
  end

  def test_persisted
    record = User.new
    refute_predicate record, :persisted?

    record.save
    assert_predicate record, :persisted?

    record.delete
    refute_predicate record, :persisted?

    record.save
    assert_predicate record, :persisted?
  end

  def test_all
    names = %w(name1 name2 name3)

    names.each do |name|
      user = User.new 'name' => name
      user.password = name
      user.save
    end

    assert_equal 3, User.all.count
    assert_equal names, User.all.map(&:name)
  end
end
