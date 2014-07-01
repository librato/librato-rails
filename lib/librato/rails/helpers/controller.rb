module Librato
  module Rails
    module Helpers
      module Controller

        # Mark a specific controller action for more detailed instrumenting
        def instrument_action(action)
          Subscribers.watch_controller_action(self.to_s, action)
        end

      end
    end
  end
end