require 'test_helper'
Librato::Rails::VersionSpecifier.supported(min: '4.2') { require 'dummy_job' }

class JobTest < ActiveSupport::IntegrationCase
  Librato::Rails::VersionSpecifier.supported(min: '4.2') do
    test 'jobs performed' do
      tags = {
        adapter: "inline_adapter",
        job: "dummy_job"
      }.merge(default_tags)

      DummyJob.perform_now

      assert_equal 1, counters.fetch("rails.job.perform", tags: tags)[:value]
      assert_equal 1, aggregate.fetch("rails.job.perform.time", tags: tags)[:count]
    end

    test 'jobs enqueued' do
      tags = {
        adapter: "inline_adapter",
        job: "dummy_job"
      }.merge(default_tags)

      DummyJob.perform_later

      assert_equal 1, counters.fetch("rails.job.enqueue", tags: tags)[:value]
    end
  end
end
