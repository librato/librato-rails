require 'test_helper'

class MetricsRailsGroupTest < ActiveSupport::TestCase
  
  test 'basic grouping' do
    Metrics::Rails.group 'fruit' do |g|
      g.increment 'bites'
      g.increment 'nibbles', 5
      
      g.measure 'banana', 12
      g.measure 'banana', 10
      
      g.timing 'grow_time', 122.2
      g.timing 'grow_time', 24.3
    end
    
    assert_equal 1, counters['fruit.bites']
    assert_equal 5, counters['fruit.nibbles']

    assert_equal 2, aggregate['fruit.banana'][:count]
    assert_equal 22, aggregate['fruit.banana'][:sum]
    
    assert_equal 2, aggregate['fruit.grow_time'][:count]
    assert_equal 146.5, aggregate['fruit.grow_time'][:sum]
  end
  
  private
  
  def aggregate
    Metrics::Rails.aggregate
  end
  
  def counters
    Metrics::Rails.counters
  end
  
end
