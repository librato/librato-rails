require 'test_helper'

class LibratoRailsGroupTest < MiniTest::Unit::TestCase
  
  def test_basic_grouping
    Librato::Rails.group 'fruit' do |g|
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
  
  def test_nesting
    Librato::Rails.group 'street' do |s|
      s.increment 'count'
      s.group 'market' do |m|
        m.increment 'tenants', 10
      end
    end
    
    assert_equal 1, counters['street.count']
    assert_equal 10, counters['street.market.tenants']
  end
  
  private
  
  def aggregate
    Librato::Rails.aggregate
  end
  
  def counters
    Librato::Rails.counters
  end
  
end
