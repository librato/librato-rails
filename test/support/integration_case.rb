class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  
  setup do
    # remove any accumulated metrics
    Metrics::Rails.delete_all
  end
  
  private
  
  def aggregate
    Metrics::Rails.aggregate
  end
  
  def counters
    Metrics::Rails.counters
  end
end