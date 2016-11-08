require 'test_helper'

module Librato
  module Rails
    class ConfigTest < MiniTest::Unit::TestCase

      def teardown
        ENV.delete('LIBRATO_USER')
        ENV.delete('LIBRATO_TOKEN')
        ENV.delete("LIBRATO_TAGS")
        # legacy
        ENV.delete('LIBRATO_METRICS_USER')
        ENV.delete('LIBRATO_METRICS_TOKEN')
        ENV.delete("LIBRATO_METRICS_TAGS")
      end

      def test_environmental_variable_config
        ENV['LIBRATO_USER'] = 'foo@bar.com'
        ENV['LIBRATO_TOKEN'] = 'api_key'
        ENV["LIBRATO_TAGS"] = "foo=bar"
        ENV['LIBRATO_SUITES'] = 'all'
        config = Configuration.new
        assert_equal 'foo@bar.com', config.user
        assert_equal 'api_key', config.token
        assert_equal "bar", config.tags[:foo]
        assert_equal 'all', config.suites
        assert config.has_tags?, "tags are explicit"
      end

      def test_config_file_config
        config = fixture_config
        assert_equal 'test@bar.com', config.user
        assert_equal 'test api key', config.token
        assert_equal 'rails-test', config.prefix
        assert_equal 30, config.flush_interval
        assert_equal "us-east-1", config.tags[:region]
        assert_equal "b", config.tags[:az]
        assert_equal 'http://localhost:8080', config.proxy
        assert_equal 'all', config.suites
        assert config.has_tags?, "tags are not explicit"
      end

      def test_detect_tags
        config = fixture_config('simple')
        assert_equal 'test@bar.com', config.user
        assert_equal 'test api key', config.token
        config = fixture_config
        assert config.tags[:host]                       # default tag
        assert_equal "dummy", config.tags[:service]     # default tag
        assert_equal "test", config.tags[:environment]  # default tag
        assert_equal "us-east-1", config.tags[:region]  # custom tag
      end

      def test_environmental_and_config_file_config
        ENV['LIBRATO_METRICS_USER'] = 'foo@bar.com'
        ENV['LIBRATO_METRICS_TOKEN'] = 'api_key'
        config = fixture_config
        assert_equal 'test@bar.com', config.user # from config file
        assert_equal 'test api key', config.token # from config file
        assert_equal 'rails-test', config.prefix # from config file
        assert_equal "us-east-1", config.tags[:region] # from config file
        assert_equal "b", config.tags[:az] # from config file
        assert_equal 30, config.flush_interval # from config file
      end

      def test_empty_config_file_doesnt_break_log_level
        config = fixture_config('empty')
        assert_equal :info, config.log_level, 'should be default'
      end

      def test_empty_config_file_doesnt_break_suites
        config = fixture_config('empty')
        assert_equal '', config.suites, 'should be default'
      end

      def test_default_suites
        defaults = Configuration.new.send(:default_suites)
        assert_includes defaults, :rack
        assert_includes defaults, :rack_method
        assert_includes defaults, :rack_status
        assert_includes defaults, :rails_cache
        assert_includes defaults, :rails_controller
        assert_includes defaults, :rails_mail
        assert_includes defaults, :rails_method
        assert_includes defaults, :rails_render
        assert_includes defaults, :rails_sql
        assert_includes defaults, :rails_status
        assert_includes defaults, :rails_job
      end

      def fixture_config(file='librato')
        fixture_config = File.join(File.dirname(__FILE__), "../fixtures/config/#{file}.yml")
        Configuration.new(:config_file => fixture_config)
      end

    end
  end
end
