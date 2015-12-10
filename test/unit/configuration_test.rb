require 'test_helper'

module Librato
  module Rails
    class ConfigTest < MiniTest::Unit::TestCase

      def teardown
        ENV.delete('LIBRATO_USER')
        ENV.delete('LIBRATO_TOKEN')
        ENV.delete('LIBRATO_SOURCE')
        # legacy
        ENV.delete('LIBRATO_METRICS_USER')
        ENV.delete('LIBRATO_METRICS_TOKEN')
        ENV.delete('LIBRATO_METRICS_SOURCE')
      end

      def test_environmental_variable_config
        ENV['LIBRATO_USER'] = 'foo@bar.com'
        ENV['LIBRATO_TOKEN'] = 'api_key'
        ENV['LIBRATO_SOURCE'] = 'source'
        config = Configuration.new
        assert_equal 'foo@bar.com', config.user
        assert_equal 'api_key', config.token
        assert_equal 'source', config.source
        assert config.explicit_source?, 'source is explicit'
      end

      def test_legacy_env_variable_config
        ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
        ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
        ENV['LIBRATO_METRICS_SOURCE'] = 'source'
        config = Configuration.new
        assert_equal 'foo@bar.com', config.user
        assert_equal 'api_key', config.token
        assert_equal 'source', config.source
        assert config.explicit_source?, 'source is explicit'
      end

      def test_config_file_config
        config = fixture_config
        assert_equal 'test@bar.com', config.user
        assert_equal 'test api key', config.token
        assert_equal 'rails-test', config.prefix
        assert_equal 30, config.flush_interval
        assert_equal 'custom-1', config.source
        assert_equal false, config.source_pids
        assert_equal 'http://localhost:8080', config.proxy
        assert config.explicit_source?, 'source is explicit'
      end

      def test_implicit_source
        config = fixture_config('simple')
        assert_equal 'test@bar.com', config.user
        assert_equal 'test api key', config.token
        assert !config.explicit_source?, 'source is not explicit'
      end

      def test_environmental_and_config_file_config
        ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
        ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
        ENV['LIBRATO_METRICS_SOURCE'] = 'source'
        config = fixture_config
        assert_equal 'test@bar.com', config.user # from config file
        assert_equal 'test api key', config.token # from config file
        assert_equal 'rails-test', config.prefix # from config file
        assert_equal 30, config.flush_interval # from config file
      end

      def test_empty_config_file_doesnt_break_log_level
        config = fixture_config('empty')
        assert_equal :info, config.log_level, 'should be default'
      end

      def fixture_config(file='librato')
        fixture_config = File.join(File.dirname(__FILE__), "../fixtures/config/#{file}.yml")
        Configuration.new(:config_file => fixture_config)
      end

    end
  end
end
