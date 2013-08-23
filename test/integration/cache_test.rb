require 'test_helper'

class CacheTest < ActiveSupport::IntegrationCase

  test 'cache read' do
    visit cache_read_path

    assert_equal 1, counters["rails.cache.read"]
    assert_equal 1, aggregate["rails.cache.read.time"][:count]
  end

  test 'cache write' do
    visit cache_write_path

    assert_equal 1, counters["rails.cache.write"]
    assert_equal 1, aggregate["rails.cache.write.time"][:count]
  end

  test 'cache fetch_hit' do
    visit cache_fetch_hit_path

    assert_equal 1, counters["rails.cache.fetch_hit"]
    assert_equal 1, aggregate["rails.cache.fetch_hit.time"][:count]
  end

  test 'cache generate' do
    visit cache_generate_path

    assert_equal 1, counters["rails.cache.generate"]
    assert_equal 1, aggregate["rails.cache.generate.time"][:count]
  end

  test 'cache delete' do
    visit cache_delete_path

    assert_equal 1, counters["rails.cache.delete"]
    assert_equal 1, aggregate["rails.cache.delete.time"][:count]
  end

end
