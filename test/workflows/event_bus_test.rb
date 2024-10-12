require 'test_helper'

class EventBusTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  class TestWorkflow < DurableFlow::Workflow
    subscribe_to 'test_event'

    def execute
      step :test_step do
        "executed"
      end
    end
  end

  test "publishes event and triggers subscribed workflow" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    assert_difference -> { DurableFlow::WorkflowInstance.count } => 1 do
      assert_enqueued_with(job: WorkflowJob) do
        DurableFlow::EventBus.publish(event)
      end
    end

    assert_difference -> { DurableFlow::StepExecution.count } => 1 do
      perform_enqueued_jobs
    end

    workflow_instance = DurableFlow::WorkflowInstance.last
    step_execution = DurableFlow::StepExecution.last
    assert_equal TestWorkflow.name, workflow_instance.name

    assert_equal 'test_step', step_execution.name
    assert_equal 'completed', step_execution.status
    assert_equal 'executed', step_execution.output
  end

  test "does not trigger unsubscribed workflows" do
    event = durable_flow_events(:two)

    assert_no_difference -> { DurableFlow::WorkflowInstance.count } do
      assert_no_enqueued_jobs do
        DurableFlow::EventBus.publish(event)
      end
    end
  end

  test "prevents duplicate subscriptions" do
    event_name = 'test_duplicate_event'

    # Subscribe the same workflow twice
    DurableFlow::EventBus.subscribe(event_name, TestWorkflow)
    DurableFlow::EventBus.subscribe(event_name, TestWorkflow)

    # Check that the subscription list for the event contains only one instance of TestWorkflow
    subscriptions = DurableFlow::EventBus.subscriptions[event_name]
    assert_equal 1, subscriptions.count
    assert_equal TestWorkflow, subscriptions.first
  end
end
