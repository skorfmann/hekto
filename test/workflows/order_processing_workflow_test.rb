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
    assert_enqueued_with(job: OrderProcessingWorkflow) do
      workflow = OrderProcessingWorkflow.run(event: event, account: account)
    end

    assert_instance_of OrderProcessingWorkflow, workflow

    perform_enqueued_jobs

    result = workflow.reload.result

    expected_result = [
      { "name" => "John Doe", "email" => "john@example.com" }
    ]
    assert_equal expected_result, result
  end
end