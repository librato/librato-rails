require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase
  
  # Each request
  
  test 'increment total and status' do
    visit root_path
    
    assert_equal 1, counters['request.total']
    assert_equal 1, counters['request.status.200']
    assert_equal 1, counters['request.status.2xx']
  end
  
end