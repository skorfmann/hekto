class DurableFlow::Workflow

  class << self
    def run(event:, account:)
      workflow_instance = DurableFlow::WorkflowInstance.create!(
        account: account,
        event: event,
        name: self.name,
        status: 'pending'
      )
      WorkflowJob.perform_later(workflow_instance.id)
    end
  end

  attr_reader :workflow_instance, :event

  def initialize(workflow_instance)
    @workflow_instance = workflow_instance
    @event = workflow_instance.event
    @steps = ActiveSupport::OrderedHash.new
  end

  def execute
    raise NotImplementedError, "Subclasses must implement the execute method"
  end

  def sleep_for(name, duration)
    step_execution = find_or_create_step_execution(name)

    return true if step_execution.completed?

    if step_execution.sleep_until.nil?
      step_execution.update!(sleep_until: Time.current + duration, status: :sleeping)
    end

    if Time.current < step_execution.sleep_until
      remaining_time = step_execution.sleep_until - Time.current
      WorkflowJob.set(wait: remaining_time).perform_later(workflow_instance.id)
      throw :pause_workflow
    end

    step_execution.update!(status: :completed)
    true
  end

  def step(name, &block)
    step_execution = find_or_create_step_execution(name)

    return step_execution.output if step_execution.completed?

    begin
      result = instance_eval(&block)
      step_execution.update!(
        output: result,
        status: :completed
      )
      result
    rescue => e
      step_execution.update!(
        error: { message: e.message, backtrace: e.backtrace },
        status: :failed
      )
      raise e
    end
  end

  private

  def find_next_step
    @steps.keys.find { |step_name| !step_completed?(step_name) }
  end

  def step_completed?(name)
    step_execution = find_step_execution(name)
    step_execution&.completed?
  end

  def find_or_create_step_execution(name)
    DurableFlow::StepExecution.find_or_create_by!(
      workflow_instance: workflow_instance,
      account: workflow_instance.account,
      name: name
    ) do |execution|
      execution.status = :pending
      execution.input = get_step_input(name)
    end
  end

  def find_step_execution(name)
    DurableFlow::StepExecution.find_by(
      workflow_instance: workflow_instance,
      name: name
    )
  end

  def get_step_input(name)
    # Implement logic to determine input for the step
    # This could be based on previous steps' outputs or initial workflow data
    {}
  end

  def workflow_completed?
    @steps.keys.all? { |step_name| step_completed?(step_name) }
  end

  def set(key, value)
    # This method would update the workflow state
    # For now, it's a placeholder
  end

  def get(key)
    # This method would retrieve data from the workflow state
    # For now, it's a placeholder
  end
end
