require 'test_helper'

class MetricsRailsCounterCacheTest < MiniTest::Unit::TestCase
  
  def test_basic_operations
    cc = Metrics::Rails::CounterCache.new
    cc.increment :foo
    assert_equal 1, cc[:foo]
    
    # accepts optional argument
    cc.increment :foo, 5
    assert_equal 6, cc[:foo]
    
    # strings or symbols work
    cc.increment 'foo'
    assert_equal 7, cc['foo']
  end
  
end