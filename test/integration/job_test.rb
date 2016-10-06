require 'test_helper'

class JobTest < ActiveSupport::IntegrationCase
  Librato::Rails::VersionSpecifier.supported(min: '4.2') do
    test 'jobs performed' do
      tags = {
        adapter: "InlineAdapter",
        job: "DummyJob"
      }

      DummyJob.perform_now

      assert_equal 1, counters.fetch("rails.job.perform", tags: tags)[:value]
      assert_equal 1, aggregate.fetch("rails.job.perform.time", tags: tags)[:count]
    end

    test 'jobs enqueued' do
      tags = {
        adapter: "InlineAdapter",
        job: "DummyJob"
      }

      DummyJob.perform_later

      assert_equal 1, counters.fetch("rails.job.enqueue", tags: tags)[:value]
    end
  end
end
