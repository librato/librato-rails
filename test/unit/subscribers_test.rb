require 'test_helper'

module Librato
  module Rails
    class SubscribersTest < MiniTest::Unit::TestCase

      def test_watch_controller_descendants
        expected = %w(BaseController IntermediateController DerivedController)
        actual = Subscribers.watch_controller_descendants_for('BaseController')

        assert expected.to_set.subset?(actual.to_set)
      end

      def test_track_descendants
        assert Subscribers.track_controller_descendants.exclude?('#')
      end

    end
  end
end
