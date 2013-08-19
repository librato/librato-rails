require 'test_helper'

module Librato
  module Rails
    class TrackerTest < MiniTest::Unit::TestCase

      def test_user_agent
        config = Configuration.new
        tracker = Tracker.new(config)
        assert_match /librato\-rails/, tracker.send(:user_agent)
      end

    end
  end
end
