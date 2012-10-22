require 'test_helper'

class LibratoRailsCounterCacheTest < MiniTest::Unit::TestCase
  
  def test_basic_operations
    cc = Librato::Rails::CounterCache.new
    cc.increment :foo
    assert_equal 1, cc[:foo]
    
    # accepts optional argument
    cc.increment :foo, :by => 5
    assert_equal 6, cc[:foo]
    
    # legacy style
    cc.increment :foo, 2
    assert_equal 8, cc[:foo]
    
    # strings or symbols work
    cc.increment 'foo'
    assert_equal 9, cc['foo']
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
  
  def test_flushing
    cc = Librato::Rails::CounterCache.new
    
    cc.increment :foo
    cc.increment :bar, :by => 2
    cc.increment :foo, :source => 'foobar'
    cc.increment :foo, :source => 'foobar', :by => 3
    
    q = Librato::Metrics::Queue.new
    cc.flush_to(q)
    
    expected = Set.new [{:name=>"foo", :value=>1},
                {:name=>"foo", :value=>4, :source=>"foobar"},
                {:name=>"bar", :value=>2}]
    queued = Set.new q.gauges
    queued.each { |hash| hash.delete(:measure_time) } 
    assert_equal queued, expected
  end
  
end