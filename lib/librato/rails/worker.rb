module Librato
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
      
      def logger
        Librato::Rails.logger
      end
      
      # run the given block every <period> seconds, looping
      # infinitely unless @interrupt becomes true.
      #
      def run_periodically(period, &block)
        next_run = start_time(period)
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
      
      # Give some structure to worker start times so when possible
      # they will be in sync.
      def start_time(period)
        earliest = Time.now + period
        # already on a whole minute
        return earliest if earliest.sec == 0 
        if period > 30
          # bump to whole minute
          earliest + (60-earliest.sec)
        else
          # ensure sync to whole minute if minute is evenly divisible
          earliest + (period-(earliest.sec%period))
        end
      end
      
    end
    
  end
end