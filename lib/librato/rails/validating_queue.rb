# this functionality should probably be available in librato-metrics
# eventually, spiking here for now to work out the kinks
module Librato
  module Rails
    class ValidatingQueue < Librato::Metrics::Queue
      LOGGER = Librato::Rails
      METRIC_NAME_REGEX = /\A[-.:_\w]{1,255}\z/
      SOURCE_NAME_REGEX = /\A[-:A-Za-z0-9_.]{1,255}\z/

      # screen all measurements for validity before sending
      def submit
        @queued[:gauges].delete_if do |entry|
          name = entry[:name].to_s
          if name !~ METRIC_NAME_REGEX
            LOGGER.log :warn, "metric name '#{name}' is invalid, not sending"
            true # delete
          else
            false # preserve
          end
        end
        super
      end

    end
  end
end