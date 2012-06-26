require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase
  
  # Each request
  
  test 'increment total and status' do
    visit root_path
    
    assert_equal 1, counters['request.total']
    assert_equal 1, counters['request.status.200']
    assert_equal 1, counters['request.status.2xx']
    
    visit '/status/204'
    
    assert_equal 2, counters['request.total']
    assert_equal 1, counters['request.status.200']
    assert_equal 1, counters['request.status.204']
    assert_equal 2, counters['request.status.2xx']
  end
  
  test 'track exceptions' do
    visit exception_path rescue nil
    assert_equal 1, counters['request.exceptions']
  end
  
  test 'track slow requests' do
    visit slow_path
    assert_equal 1, counters['request.slow']
  end
  
end