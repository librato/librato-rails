require 'test_helper'

class MetricsRailsTest < ActiveSupport::TestCase
  
  test 'is a module' do
    assert_kind_of Module, Metrics::Rails
  end
  
  test 'client is available' do
    assert_kind_of Librato::Metrics::Client, Metrics::Rails.client
  end
  
  test 'flush sends data' do
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
  
  private
  
  def delete_all_metrics
    client = Metrics::Rails.client
    client.list.each do |metric|
      client.connection.delete("metrics/#{metric['name']}")
    end
  end
  
end
