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
      assert_equal 1, counters["rails.sql.inserts"][:value]
    end

    assert_increasing_queries do
      prev =
        if counters["rails.sql.selects"]
          counters["rails.sql.selects"][:value].to_i
        else
          0
        end
      foo = User.find_by_email('foo@foo.com')
      assert_equal prev+1, counters["rails.sql.selects"][:value]
    end

    assert_increasing_queries do
      foo.password = 'new password'
      foo.save
      assert_equal 1, counters["rails.sql.updates"][:value]
    end

    assert_increasing_queries do
      foo.destroy
      assert_equal 1, counters["rails.sql.deletes"][:value]
    end
  end

  private

  def assert_increasing_queries
    previous =
      if counters["rails.sql.queries"]
        counters["rails.sql.queries"][:value].to_i
      else
        0
      end
    yield
    assert counters["rails.sql.queries"][:value].to_i > previous
  end

end
