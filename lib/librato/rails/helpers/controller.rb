module Librato
  module Rails
    module Helpers
      module Controller

        # Mark a specific controller action for more detailed instrumenting, or all actions if no *actions passed in
        # Add to self.inherited if you also want to enable this in subclasses
        def instrument_action(*actions)
          if actions.count > 0
            actions.each do |action|
              Subscribers.watch_controller_action(self.to_s, action)
            end
          else
            Subscribers.watch_controller(self.to_s)
          end
        end
      end
    end
  end
end

