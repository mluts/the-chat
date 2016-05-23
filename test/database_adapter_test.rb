require 'securerandom'

module DatabaseAdapterTest
  def test_find_finds_the_record
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    id = adapter.save(table, attrs)
    assert_equal attrs, adapter.find(table, id)
  end

  def test_find_returns_nil_when_cant_find
    assert_nil adapter.find('foo', 'bar')
  end

  def test_find_raises_error_when_table_is_nil
    assert_raises adapter.class::FindError do
      adapter.find(nil, '1')
    end
  end

  def test_find_doesnt_raise_error_when_id_is_nil
    assert_nil adapter.find('table', nil)
  end

  def test_save_returns_record_id_string
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    id = adapter.save(table, attrs)
    assert_instance_of String, id
    assert_equal attrs, adapter.find(table, id)
  end

  def test_save_allows_override_record
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    id = adapter.save(table, attrs)
    adapter.save(table, {}, id)
    assert_equal({}, adapter.find(table, id))
  end

  def test_delete_deletes_the_record
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    id = adapter.save(table, attrs)
    assert_equal attrs, adapter.find(table, id)
    assert_equal attrs, adapter.delete(table, id)
    assert_nil adapter.find(table, id)
  end

  def test_delete_returns_nil_when_record_doesnt_exist
    table = 'users'
    assert_nil adapter.delete(table, 'id')
  end

  def test_delete_raises_error_when_table_not_provided
    assert_raises adapter.class::DeleteError do
      adapter.delete(nil, 'id')
    end
  end

  def test_select_finds_all_matched_records
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    attrs2 = {
      'foo' => '1', 'bar' => 'baz'
    }

    attrs3 = {
      'foo' => '2', 'bar' => 'baz'
    }

    id1 = adapter.save(table, attrs)
    id2 = adapter.save(table, attrs2)
    id3 = adapter.save(table, attrs3)

    assert_equal({ id1 => attrs  }, adapter.select(table, 'foo' => 'bar'))
    assert_equal({ id2 => attrs2 }, adapter.select(table, 'foo' => '1'))
    assert_equal({ id3 => attrs3 }, adapter.select(table, 'foo' => '2'))

    assert_equal({
      id1 => attrs,
      id2 => attrs2,
      id3 => attrs3
    }, adapter.select(table, 'bar' => 'baz'))

    assert_equal({
      id1 => attrs,
      id2 => attrs2,
      id3 => attrs3
    }, adapter.select(table, 'foo' => ['bar', '1', '2']))

    assert_equal({}, adapter.select(table, 'foo' => '4'))
  end

  def test_first_finds_first_matched_record
    table = 'users'
    attrs = {
      'foo' => 'bar',
      'bar' => 'baz'
    }

    attrs2 = {
      'foo' => '1', 'bar' => 'baz'
    }

    attrs3 = {
      'foo' => '2', 'bar' => 'baz'
    }

    id1 = adapter.save(table, attrs)
    id2 = adapter.save(table, attrs2)
    id3 = adapter.save(table, attrs3)

    assert_equal [id1, attrs], adapter.first(table, 'foo' => 'bar')
    assert_equal [id2, attrs2], adapter.first(table, 'foo' => '1')
    assert_equal [id3, attrs3], adapter.first(table, 'foo' => '2')

    assert_equal nil, adapter.first(table, 'foo' => '4')
  end
end
