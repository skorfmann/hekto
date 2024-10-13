module DurableFlow
  class EventBus
    class << self
      def subscribe(event_name, workflow_class)
        subscriptions[event_name] ||= []
        # Add the workflow_class only if it's not already present
        subscriptions[event_name] << workflow_class unless subscriptions[event_name].include?(workflow_class)
      end

      def publish(event)
        workflows = subscriptions[event.name.to_sym] || []
        if workflows.empty?
          Rails.logger.warn "No subscribers found for event: #{event.name}"
        else
          workflows.each do |workflow_class|
            workflow_class.run(event: event, account: event.account)
          end
        end
      end

      def subscriptions
        @subscriptions ||= {}
      end
    end
  end
end
