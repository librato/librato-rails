# module Librato
#   module Rails
#     module Subscribers
#
#       # Render operations
#
#       %w{partial template}.each do |metric|
#
#         ActiveSupport::Notifications.subscribe "render_#{metric}.action_view" do |*args|
#           event = ActiveSupport::Notifications::Event.new(*args)
#           path = event.payload[:identifier].split('/views/', 2)
#
#           if path[1]
#             source = path[1].gsub('/', ':')
#             # trim leading underscore for partial sources
#             source.gsub!(':_', ':') if metric == 'partial'
#             collector.group "rails.view" do |c|
#               c.increment "render_#{metric}", source: source, sporadic: true
#               c.timing "render_#{metric}.time", event.duration, source: source, sporadic: true
#             end
#           end
#         end
#
#       end
#
#     end
#   end
# end