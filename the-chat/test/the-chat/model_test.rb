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

  # def test_it_can_be_saved
  #   record = User.new
  #   record.name = sample_name
  #   record.password = sample_password
  #   record.save
  # end
end
