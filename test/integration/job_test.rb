require 'test_helper'

class JobTest < ActiveSupport::IntegrationCase
  Librato::Rails::VersionSpecifier.supported(min: '4.2') do
    test 'jobs performed' do
      expected_tags = {
        adapter: "ActiveJob::QueueAdapters::InlineAdapter",
        job: "DummyJob"
      }

      DummyJob.perform_now

      assert_equal 1, counters.fetch("rails.job.perform", tags: expected_tags)
      assert_equal 1, aggregate.fetch("rails.job.perform.time", tags: expected_tags)[:count]
    end

    test 'jobs enqueued' do
      expected_tags = {
        adapter: "ActiveJob::QueueAdapters::InlineAdapter",
        job: "DummyJob"
      }

      DummyJob.perform_later

      assert_equal 1, counters.fetch("rails.job.enqueue", tags: expected_tags)
    end
  end
end
