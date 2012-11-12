require 'test_helper'

class LibratoRailsConfigTest < MiniTest::Unit::TestCase

  def setup
    Librato::Rails.explicit_source = nil
  end

  def teardown
    ENV.delete('LIBRATO_USER')
    ENV.delete('LIBRATO_TOKEN')
    ENV.delete('LIBRATO_SOURCE')
    # legacy
    ENV.delete('LIBRATO_METRICS_USER')
    ENV.delete('LIBRATO_METRICS_TOKEN')
    ENV.delete('LIBRATO_METRICS_SOURCE')
    Librato::Rails.check_config
    Librato::Rails.prefix = nil
    Librato::Rails.explicit_source = nil
  end

  def test_environmental_variable_config
    ENV['LIBRATO_USER'] = 'foo@bar.com'
    ENV['LIBRATO_TOKEN'] = 'api_key'
    ENV['LIBRATO_SOURCE'] = 'source'
    Librato::Rails.check_config
    assert_equal 'foo@bar.com', Librato::Rails.user
    assert_equal 'api_key', Librato::Rails.token
    assert_equal 'source', Librato::Rails.source
    assert Librato::Rails.explicit_source, 'source is explicit'
  end

  def test_legacy_env_variable_config
    ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
    ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
    ENV['LIBRATO_METRICS_SOURCE'] = 'source'
    Librato::Rails.check_config
    assert_equal 'foo@bar.com', Librato::Rails.user
    assert_equal 'api_key', Librato::Rails.token
    assert_equal 'source', Librato::Rails.source
    assert Librato::Rails.explicit_source, 'source is explicit'
  end

  def test_config_file_config
    with_fixture_config do
      assert_equal 'test@bar.com', Librato::Rails.user
      assert_equal 'test api key', Librato::Rails.token
      assert_equal 'rails-test', Librato::Rails.prefix
      assert_equal 30, Librato::Rails.flush_interval
      assert_equal 'custom-1', Librato::Rails.source
      assert_equal false, Librato::Rails.source_pids
      assert Librato::Rails.explicit_source, 'source is explicit'
    end
  end

  def test_implicit_source
    with_fixture_config('simple') do
      assert_equal 'test@bar.com', Librato::Rails.user
      assert_equal 'test api key', Librato::Rails.token
      assert !Librato::Rails.explicit_source, 'source is not explicit'
    end
  end

  def test_environmental_and_config_file_config
    ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
    ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
    ENV['LIBRATO_METRICS_SOURCE'] = 'source'
    with_fixture_config do
      assert_equal 'test@bar.com', Librato::Rails.user # from config file
      assert_equal 'test api key', Librato::Rails.token # from config file
      assert_equal 'rails-test', Librato::Rails.prefix # from config file
      assert_equal 30, Librato::Rails.flush_interval # from config file
    end
  end

  def with_fixture_config(file='librato')
    fixture_config = File.join(File.dirname(__FILE__), "../fixtures/config/#{file}.yml")
    previous, Librato::Rails.config_file = Librato::Rails.config_file, fixture_config
    Librato::Rails.check_config
    yield
  ensure
    Librato::Rails.config_file = previous
  end

end
