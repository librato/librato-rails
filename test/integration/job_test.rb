require 'test_helper'

class JobTest < ActiveSupport::IntegrationCase
  Librato::Rails::VersionSpecifier.supported(min: '4.2') do
    test 'jobs performed' do
      DummyJob.perform_now

      assert_equal 1, counters['rails.job.perform']
      assert_equal 1, aggregate.fetch('rails.job.perform.time', source: 'DummyJob')[:count]
    end

    test 'jobs enqueued' do
      DummyJob.perform_later

      assert_equal 1, counters['rails.job.enqueue']
    end
  end
end
