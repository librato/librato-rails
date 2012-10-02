require 'test_helper'

class LibratoRailsAggregatorTest < MiniTest::Unit::TestCase

  def teardown
    ENV.delete('LIBRATO_METRICS_USER')
    ENV.delete('LIBRATO_METRICS_TOKEN')
    ENV.delete('LIBRATO_METRICS_SOURCE')
    Librato::Rails.check_config
  end

  def test_environmental_variable_config
    ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
    ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
    ENV['LIBRATO_METRICS_SOURCE'] = 'source'
    Librato::Rails.check_config
    assert_equal 'foo@bar.com', Librato::Rails.user
    assert_equal 'api_key', Librato::Rails.token
    assert_equal 'source', Librato::Rails.source
  end

  def test_config_file_config
    with_fixture_config do
      assert_equal 'test@bar.com', Librato::Rails.user
      assert_equal 'test api key', Librato::Rails.token
      assert_equal 'rails-test', Librato::Rails.prefix
      assert_equal 30, Librato::Rails.flush_interval
      assert_equal 'custom-1', Librato::Rails.source
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

  def with_fixture_config
    fixture_config = File.join(File.dirname(__FILE__), '../fixtures/config/librato.yml')
    previous, Librato::Rails.config_file = Librato::Rails.config_file, fixture_config
    Librato::Rails.check_config
    yield
  ensure
    Librato::Rails.config_file = previous
  end

end
