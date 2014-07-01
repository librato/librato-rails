require 'test_helper'

class SQLTest < ActiveSupport::IntegrationCase

  # Query tests - the numbers specified assume running against SQLite

  test 'total queries and query types' do
    # note that modifying queries are wrapped in a transaction which
    # adds 2 to total queries per operation.

    # rails 4.1 adds extra queries which can be variable, hence the
    # two possible counts for these operations

    foo = nil

    assert_increasing_queries do
      user = User.create!(email: 'foo@foo.com', password: 'wow')
      assert_equal 1, counters["rails.sql.inserts"]
    end

    assert_increasing_queries do
      prev = counters["rails.sql.selects"].to_i
      foo = User.find_by_email('foo@foo.com')
      assert_equal prev+1, counters["rails.sql.selects"]
    end

    assert_increasing_queries do
      foo.password = 'new password'
      foo.save
      assert_equal 1, counters["rails.sql.updates"]
    end

    assert_increasing_queries do
      foo.destroy
      assert_equal 1, counters["rails.sql.deletes"]
    end
  end

  private

  def assert_increasing_queries
    previous = counters["rails.sql.queries"].to_i
    yield
    assert counters["rails.sql.queries"].to_i > previous
  end

end
