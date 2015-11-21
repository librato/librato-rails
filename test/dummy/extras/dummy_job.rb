class DummyJob < ActiveJob::Base
  queue_as :default

  def perform
    sleep 1
  end
end
