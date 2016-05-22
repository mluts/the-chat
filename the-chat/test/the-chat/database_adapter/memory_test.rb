require 'test_helper'
require 'database_adapter_test'

class TheChat::DatabaseAdapter::MemoryTest < Minitest::Test
  def adapter
    @adapter ||= TheChat::DatabaseAdapter::Memory.new
  end

  include DatabaseAdapterTest
end
