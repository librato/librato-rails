require 'test_helper'

class MetricsRailsTest < ActiveSupport::TestCase
  
  setup do
    # delete any generated metrics
    Metrics::Rails.delete_all
  end
  
  test 'is a module' do
    assert_kind_of Module, Metrics::Rails
  end
  
  test 'client is available' do
    assert_kind_of Librato::Metrics::Client, Metrics::Rails.client
  end
  
  test '#increment exists' do
    assert Metrics::Rails.respond_to?(:increment)
    Metrics::Rails.increment :baz, 5
  end
  
  test '#measure exists' do
    assert Metrics::Rails.respond_to?(:measure)
    Metrics::Rails.timing 'queries', 10
  end
  
  test '#timing exists' do
    assert Metrics::Rails.respond_to?(:timing)
    Metrics::Rails.timing 'request.time.total', 121.2
  end
  
  test 'flush sends counters' do
    delete_all_metrics
    Metrics::Rails.increment :foo
    Metrics::Rails.increment :bar, 2
    Metrics::Rails.increment :foo
    Metrics::Rails.flush
    
    client = Metrics::Rails.client
    metric_names = client.list.map { |m| m['name'] }
    assert metric_names.include?('rails.foo'), 'rails.foo should be present'
    assert metric_names.include?('rails.bar'), 'rails.bar should be present'
    
    foo = client.fetch 'rails.foo', :count => 10
    assert_equal 1, foo['unassigned'].length
    assert_equal 2, foo['unassigned'][0]['value']
    
    bar = client.fetch 'rails.bar', :count => 10
    assert_equal 1, bar['unassigned'].length
    assert_equal 2, bar['unassigned'][0]['value']
  end
  
  test 'counters should persist through flush' do
    Metrics::Rails.increment 'knightrider'
    Metrics::Rails.flush
    assert_equal 1, Metrics::Rails.counters['knightrider']
  end
  
  test 'flush sends measures/timings' do
    delete_all_metrics
    Metrics::Rails.timing  'request.time.total', 122.1
    Metrics::Rails.measure 'items_bought', 20
    Metrics::Rails.timing  'request.time.total', 81.3
    Metrics::Rails.flush
    
    client = Metrics::Rails.client
    metric_names = client.list.map { |m| m['name'] }
    assert metric_names.include?('rails.request.time.total'), 
      'rails.request.time.total should be present'
    assert metric_names.include?('rails.items_bought'), 
      'rails.request.time.db should be present'
    
    total = client.fetch 'rails.request.time.total', :count => 10
    assert_equal 2, total['unassigned'][0]['count']
    assert_in_delta 203.4, total['unassigned'][0]['sum'], 0.1
    
    items = client.fetch 'rails.items_bought', :count => 10
    assert_equal 1, items['unassigned'][0]['count']
    assert_in_delta 20, items['unassigned'][0]['sum'], 0.1
  end
  
  test 'flush should purge measures/timings' do
    delete_all_metrics
    
    Metrics::Rails.timing  'request.time.total', 122.1
    Metrics::Rails.measure 'items_bought', 20
    Metrics::Rails.flush
    
    assert Metrics::Rails.aggregate.empty?, 'measures and timings should be cleared with flush'
  end
  
  test 'empty flush should not be sent' do
    delete_all_metrics
    Metrics::Rails.flush
    
    assert_equal [], Metrics::Rails.client.list
  end
  
  private
  
  def delete_all_metrics
    client = Metrics::Rails.client
    client.list.each do |metric|
      client.connection.delete("metrics/#{metric['name']}")
    end
  end
  
end
