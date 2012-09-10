class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  
  setup do
    # remove any accumulated metrics
    Librato::Rails.delete_all
  end
  
  private
  
  def aggregate
    Librato::Rails.aggregate
  end
  
  def counters
    Librato::Rails.counters
  end
end