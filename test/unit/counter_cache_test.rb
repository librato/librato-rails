require 'test_helper'

class LibratoRailsCounterCacheTest < MiniTest::Unit::TestCase
  
  def test_basic_operations
    cc = Librato::Rails::CounterCache.new
    cc.increment :foo
    assert_equal 1, cc[:foo]
    
    # accepts optional argument
    cc.increment :foo, :by => 5
    assert_equal 6, cc[:foo]
    
    # strings or symbols work
    cc.increment 'foo'
    assert_equal 7, cc['foo']
  end
  
  def test_custom_sources
    cc = Librato::Rails::CounterCache.new
    
    cc.increment :foo, :source => 'bar'
    assert_equal 1, cc.fetch(:foo, :source => 'bar')
    
    # symbols also work
    cc.increment :foo, :source => :baz
    assert_equal 1, cc.fetch(:foo, :source => :baz)
    
    # strings and symbols are interchangable
    cc.increment :foo, :source => :bar
    assert_equal 2, cc.fetch(:foo, :source => 'bar')
     
    # custom source and custom increment
    cc.increment :foo, :source => 'boombah', :by => 10
    assert_equal 10, cc.fetch(:foo, :source => 'boombah')
  end
  
end