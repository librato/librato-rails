class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  setup do
    # remove any accumulated metrics
    collector.delete_all
  end

  private

  def aggregate
    collector.aggregate
  end

  def collector
    Librato.tracker.collector
  end

  def counters
    collector.counters
  end
end