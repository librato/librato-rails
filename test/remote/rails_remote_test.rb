require 'test_helper'

class LibratoRailsRemoteTest < ActiveSupport::TestCase
  
  # These tests connect to the Metrics server with an account and verify remote
  # functions. They will only run if the below environment variables are set.
  #
  # BE CAREFUL, running these tests will DELETE ALL metrics currently in the
  # test account.
  #
  if ENV['LIBRATO_RAILS_TEST_EMAIL'] && ENV['LIBRATO_RAILS_TEST_API_KEY']
  
    setup do
      # delete any generated Librato::Rails
      Librato::Rails.user = ENV['LIBRATO_RAILS_TEST_EMAIL']
      Librato::Rails.token = ENV['LIBRATO_RAILS_TEST_API_KEY']
      if ENV['LIBRATO_RAILS_TEST_API_ENDPOINT']
        Librato::Rails.api_endpoint = ENV['LIBRATO_RAILS_TEST_API_ENDPOINT']
      end
      Librato::Rails.delete_all
    end

    test 'flush sends counters' do
      delete_all_metrics
      source = Librato::Rails.qualified_source
      
      Librato::Rails.increment :foo
      Librato::Rails.increment :bar, 2
      Librato::Rails.increment :foo
      Librato::Rails.flush
    
      client = Librato::Rails.client
      metric_names = client.list.map { |m| m['name'] }
      assert metric_names.include?('foo'), 'foo should be present'
      assert metric_names.include?('bar'), 'bar should be present'

      foo = client.fetch 'foo', :count => 10
      assert_equal 1, foo[source].length
      assert_equal 2, foo[source][0]['value']
    
      bar = client.fetch 'bar', :count => 10
      assert_equal 1, bar[source].length
      assert_equal 2, bar[source][0]['value']
    end
  
    test 'counters should persist through flush' do
      Librato::Rails.increment 'knightrider'
      Librato::Rails.flush
      assert_equal 1, Librato::Rails.counters['knightrider']
    end
  
    test 'flush sends measures/timings' do
      delete_all_metrics
      source = Librato::Rails.qualified_source
      
      Librato::Rails.timing  'request.time.total', 122.1
      Librato::Rails.measure 'items_bought', 20
      Librato::Rails.timing  'request.time.total', 81.3
      Librato::Rails.flush
    
      client = Librato::Rails.client
      metric_names = client.list.map { |m| m['name'] }
      assert metric_names.include?('request.time.total'), 'request.time.total should be present'
      assert metric_names.include?('items_bought'), 'request.time.db should be present'
    
      total = client.fetch 'request.time.total', :count => 10
      assert_equal 2, total[source][0]['count']
      assert_in_delta 203.4, total[source][0]['sum'], 0.1
    
      items = client.fetch 'items_bought', :count => 10
      assert_equal 1, items[source][0]['count']
      assert_in_delta 20, items[source][0]['sum'], 0.1
    end
  
    test 'flush should purge measures/timings' do
      delete_all_metrics
    
      Librato::Rails.timing  'request.time.total', 122.1
      Librato::Rails.measure 'items_bought', 20
      Librato::Rails.flush
    
      assert Librato::Rails.aggregate.empty?, 'measures and timings should be cleared with flush'
    end
  
    test 'empty flush should not be sent' do
      delete_all_metrics
      Librato::Rails.flush
    
      assert_equal [], Librato::Rails.client.list
    end
  
    private
  
    def delete_all_metrics
      client = Librato::Rails.client
      client.list.each do |metric|
        client.connection.delete("metrics/#{metric['name']}")
      end
    end
  
  else
    puts "Skipping remote tests..."
  end
  
end
