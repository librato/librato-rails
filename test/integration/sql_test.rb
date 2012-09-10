require 'test_helper'

class SQLTest < ActiveSupport::IntegrationCase
  
  # Query tests - the numbers specified assume running against SQLite
  
  test 'total queries and query types' do
    prefix = Librato::Rails.prefix
    
    # note that modifying queries are wrapped in a transaction which
    # adds 2 to total queries per operation.
    user = User.create!(:email => 'foo@foo.com', :password => 'wow')
    assert_equal 3, counters["#{prefix}.sql.queries"]
    assert_equal 1, counters["#{prefix}.sql.inserts"]
    
    foo = User.find_by_email('foo@foo.com')
    assert_equal 4, counters["#{prefix}.sql.queries"]
    assert_equal 1, counters["#{prefix}.sql.selects"]
    
    foo.password = 'new password'
    foo.save
    assert_equal 7, counters["#{prefix}.sql.queries"]
    assert_equal 1, counters["#{prefix}.sql.updates"]
    
    foo.destroy
    assert_equal 10, counters["#{prefix}.sql.queries"]
    assert_equal 1, counters["#{prefix}.sql.deletes"]
  end
  
end
