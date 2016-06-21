module Librato
  module Rails
    module Helpers
      module Controller

        # Mark a specific controller action for more detailed instrumenting
        def instrument_action(*actions)
          actions.each do |action|
            Subscribers.watch_controller_action(self.to_s, action)
          end
        end

        def inherited(other)
          super
          Subscribers.inherit_watches(self.to_s, other.to_s)
        end

      end
    end
  end
end
