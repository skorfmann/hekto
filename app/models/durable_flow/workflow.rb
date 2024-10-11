class DurableFlow::Workflow

  class << self
    def run(event:, account:)
      workflow_instance = DurableFlow::WorkflowInstance.create!(
        account: account,
        event: event,
        name: self.name,
        status: 'pending'
      )
      new(workflow_instance, event).execute
    end
  end

  attr_reader :workflow_instance, :event

  def initialize(workflow_instance, event)
    @workflow_instance = workflow_instance
    @event = event
  end

  def execute
    raise NotImplementedError, "Subclasses must implement the execute method"
  end

  def step(name, &block)
    # This method would be implemented to handle step execution and persistence
    # For now, it's a placeholder
    result = instance_eval(&block)
    set(name, result)
    result
  end

  private

  def set(key, value)
    # This method would update the workflow state
    # For now, it's a placeholder
  end

  def get(key)
    # This method would retrieve data from the workflow state
    # For now, it's a placeholder
  end
end
