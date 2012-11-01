module Librato
  module Rails
    class Group

      def initialize(prefix)
        @prefix = "#{prefix}."
      end

      def group(prefix)
        prefix = "#{@prefix}#{prefix}"
        yield self.class.new(prefix)
      end

      def increment(counter, by=1)
        counter = "#{@prefix}#{counter}"
        Librato::Rails.increment counter, by
      end

      def measure(event, duration)
        event = "#{@prefix}#{event}"
        Librato::Rails.measure event, duration
      end
      alias :timing :measure

    end
  end
end