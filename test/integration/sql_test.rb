require 'test_helper'

class SQLTest < ActiveSupport::IntegrationCase

  # Query tests - the numbers specified assume running against SQLite

  test 'total queries and query types' do
    # note that modifying queries are wrapped in a transaction which
    # adds 2 to total queries per operation.
    user = User.create!(:email => 'foo@foo.com', :password => 'wow')
    assert_equal 3, counters["rails.sql.queries"]
    assert_equal 1, counters["rails.sql.inserts"]

    foo = User.find_by_email('foo@foo.com')
    assert_equal 4, counters["rails.sql.queries"]
    assert_equal 1, counters["rails.sql.selects"]

    foo.password = 'new password'
    foo.save
    assert_equal 7, counters["rails.sql.queries"]
    assert_equal 1, counters["rails.sql.updates"]

    foo.destroy
    assert_equal 10, counters["rails.sql.queries"]
    assert_equal 1, counters["rails.sql.deletes"]
  end

end
