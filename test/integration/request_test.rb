require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase
  
  # Each request
  
  test 'increment total and status' do
    prefix = Metrics::Rails.prefix
    visit root_path
    
    assert_equal 1, counters["#{prefix}.request.total"]
    assert_equal 1, counters["#{prefix}.request.status.200"]
    assert_equal 1, counters["#{prefix}.request.status.2xx"]
    
    visit '/status/204'
    
    assert_equal 2, counters["#{prefix}.request.total"]
    assert_equal 1, counters["#{prefix}.request.status.200"]
    assert_equal 1, counters["#{prefix}.request.status.204"]
    assert_equal 2, counters["#{prefix}.request.status.2xx"]
  end
  
  test 'request times' do
    prefix = Metrics::Rails.prefix
    visit root_path
    
    # common for all paths
    assert_equal 1, aggregate["#{prefix}.request.time"][:count], 'should record total time'
    assert_equal 1, aggregate["#{prefix}.request.time.db"][:count], 'should record db time'
    assert_equal 1, aggregate["#{prefix}.request.time.view"][:count], 'should record view time'
    
    # status specific
    assert_equal 1, aggregate["#{prefix}.request.status.200.time"][:count]
    assert_equal 1, aggregate["#{prefix}.request.status.2xx.time"][:count]
  end
  
  test 'track exceptions' do
    prefix = Metrics::Rails.prefix
    begin
      visit exception_path #rescue nil
    rescue RuntimeError => e
      raise unless e.message == 'test exception!'
    end
    assert_equal 1, counters["#{prefix}.request.exceptions"]
  end
  
  test 'track slow requests' do
    prefix = Metrics::Rails.prefix
    visit slow_path
    assert_equal 1, counters["#{prefix}.request.slow"]
  end
  
end