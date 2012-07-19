require 'test_helper'

class HelperTest < ActiveSupport::IntegrationCase
  
  test 'controller helpers' do
    visit custom_path
    
    assert_equal 1, counters['custom.visits']
    assert_equal 3, counters['custom.events']
    
    assert_equal 12, aggregate['custom.timing'][:sum]
    assert_equal 2, aggregate['custom.timing'][:count]
  end
  
  test 'model class helpers' do
    visit custom_path
    
    assert_equal 3, counters['custom.model.lookups']
    assert_equal 19.0, aggregate['custom.model.search'][:sum]
    assert_equal 2, aggregate['custom.model.search'][:count]
  end
  
  test 'model instance helpers' do
    visit custom_path
    
    assert_equal 1, counters['custom.model.touch']
  end

end
