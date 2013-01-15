require 'test_helper'

class LibratoRailsTest < ActiveSupport::TestCase
  
  test 'is a module' do
    assert_kind_of Module, Librato::Rails
  end
  
  test 'client is available' do
    assert_kind_of Librato::Metrics::Client, Librato::Rails.client
  end
  
  test '#increment exists' do
    assert Librato::Rails.respond_to?(:increment)
    Librato::Rails.increment :baz, 5
  end
  
  test '#measure exists' do
    assert Librato::Rails.respond_to?(:measure)
    Librato::Rails.timing 'queries', 10
  end
  
  test '#timing exists' do
    assert Librato::Rails.respond_to?(:timing)
    Librato::Rails.timing 'request.time.total', 121.2
  end
  
  test 'source is assignable' do
    original = Librato::Rails.source
    Librato::Rails.source = 'foobar'
    assert_equal 'foobar', Librato::Rails.source
    Librato::Rails.source = original
  end
  
  test 'qualified source includes pid' do
    assert_match /\.\d{2,6}$/, Librato::Rails.qualified_source
  end
  
  test 'qualified source does not include pid when disabled' do
    Librato::Rails.source_pids = false
    assert_match Librato::Rails.source, Librato::Rails.qualified_source
    Librato::Rails.source_pids = true
  end
end
