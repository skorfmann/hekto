require 'test_helper'

class OrderProcessingWorkflowTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "processes the workflow and returns normalized rows" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    workflow = nil
    assert_enqueued_with(job: WorkflowJob) do
      workflow = OrderProcessingWorkflow.run(event: event, account: account)
    end

    assert_instance_of WorkflowJob, workflow

    assert_difference -> { DurableFlow::StepExecution.count } => 2 do
      perform_enqueued_jobs
    end

    result = DurableFlow::WorkflowInstance.last.output

    expected_result = [
      { "name" => "John Doe", "email" => "john@example.com" }
    ]
    assert_equal expected_result, result
  end

  test "first step execution persists the correct output" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    assert_difference -> { DurableFlow::StepExecution.count } => 2 do
      OrderProcessingWorkflow.run(event: event, account: account)
      perform_enqueued_jobs
    end

    first_step_execution = DurableFlow::StepExecution.find_by(name: 'parse_csv')
    assert_not_nil first_step_execution
    assert_equal 'completed', first_step_execution.status

    expected_output = [{
      'Name' => 'John Doe',
      'Email' => 'john@example.com'
    }]
    assert_equal expected_output, first_step_execution.output
  end

  test "second step execution normalizes the data correctly" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    assert_difference -> { DurableFlow::StepExecution.count } => 2 do
      OrderProcessingWorkflow.run(event: event, account: account)
      perform_enqueued_jobs
    end

    second_step_execution = DurableFlow::StepExecution.find_by(name: 'normalize_raw_csv')
    assert_not_nil second_step_execution
    assert_equal 'completed', second_step_execution.status

    expected_output = [
      { "name" => "John Doe", "email" => "john@example.com" }
    ]
    assert_equal expected_output, second_step_execution.output
  end
end