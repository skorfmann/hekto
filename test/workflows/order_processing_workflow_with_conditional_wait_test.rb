require 'test_helper'

class OrderProcessingWorkflowWithConditionalWaitTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "workflow skips wait when there's only one row" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    travel_to Time.current do
      assert_difference -> { DurableFlow::StepExecution.count } => 2 do
        OrderProcessingWorkflowWithConditionalWait.run(event: event, account: account)
        perform_enqueued_jobs
      end

      assert_nil DurableFlow::StepExecution.find_by(name: 'the_end_of_time')

      final_step_execution = DurableFlow::StepExecution.last
      assert_equal 'completed', final_step_execution.status
      assert_equal [{ "name" => "John Doe", "email" => "john@example.com" }], final_step_execution.output
    end
  end
end
