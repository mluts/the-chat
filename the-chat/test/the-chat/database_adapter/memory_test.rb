require 'test_helper'

class TheChat::DatabaseAdapter::MemoryTest < Minitest::Test
  def adapter
    @adapter ||= TheChat::DatabaseAdapter::Memory.new
  end

  include DatabaseAdapterTest
end
