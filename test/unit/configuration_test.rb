require 'test_helper'

class MetricsRailsAggregatorTest < ActiveSupport::TestCase
  
  test 'environmental variable config' do
    ENV['METRICS_EMAIL'] = 'foo@bar.com'
    ENV['METRICS_API_KEY'] = 'api_key'
    Metrics::Rails.check_config
    assert_equal 'foo@bar.com', Metrics::Rails.email
    assert_equal 'api_key', Metrics::Rails.api_key
  end
  
  test 'config file config' do
    with_fixture_config do
      assert_equal 'test@bar.com', Metrics::Rails.email
      assert_equal 'test api key', Metrics::Rails.api_key
      assert_equal 'rails-test', Metrics::Rails.prefix
      assert_equal 30, Metrics::Rails.flush_interval
      assert_equal 'custom-1', Metrics::Rails.source
    end
  end
  
  test 'environmental and config file config' do
    ENV['METRICS_EMAIL'] = 'foo@bar.com'
    ENV['METRICS_API_KEY'] = 'api_key'
    with_fixture_config do
      assert_equal 'foo@bar.com', Metrics::Rails.email # from env
      assert_equal 'api_key', Metrics::Rails.api_key # from env
      assert_equal 'rails-test', Metrics::Rails.prefix # from config file
      assert_equal 30, Metrics::Rails.flush_interval # from config file
    end
  end
  
  def teardown
    ENV.delete('METRICS_EMAIL')
    ENV.delete('METRICS_API_KEY')
    Metrics::Rails.check_config
  end
  
  def with_fixture_config
    fixture_config = File.join(File.dirname(__FILE__), '../fixtures/config/metrics.yml')
    previous, Metrics::Rails.config_file = Metrics::Rails.config_file, fixture_config
    Metrics::Rails.check_config
    yield
  ensure
    Metrics::Rails.config_file = previous
  end
  
end
