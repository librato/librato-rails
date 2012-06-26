class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  
  private
  
  def counters
    Metrics::Rails.counters
  end
end