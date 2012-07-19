require 'test_helper'

class HelperTest < ActiveSupport::IntegrationCase
  
  test 'controller helpers' do
    visit custom_path
    
    assert_equal 1, counters['custom.visits']
    assert_equal 3, counters['custom.events']
    
    assert_equal 12, aggregate['custom.timing'][:sum]
    assert_equal 2, aggregate['custom.timing'][:count]
  end
  
  # test 'model helpers' do
  #   visit custom_path
  #   
  #   assert_equal 2, counters['custom.model.lookups']
  # end
  
end
