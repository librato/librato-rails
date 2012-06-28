require 'thread'

module Metrics
  module Rails
    
    # This class manages the background thread which submits all data
    # to the Librato Metrics service.
    class Worker
      
      def initialize
        @interrupt = false
      end
      
      # do the assigned work, catching some special cases
      #
      def execute(obj)
        obj.call
      end
      
      def log
        Metrics::Rails.log
      end
      
      # run the given block every <period> seconds, looping
      # infinitely unless @interrupt becomes true.
      #
      def run_periodically(period, &block)
        next_run = Time.now + period
        until @interrupt do
          now = Time.now
          if now >= next_run
            execute(block) # runs given block
            while next_run <= now
              next_run += period
            end
          else
            sleep (next_run - now)
          end
        end
      end
      
    end
    
  end
end