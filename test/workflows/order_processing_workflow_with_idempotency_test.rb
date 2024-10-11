require 'test_helper'

class OrderProcessingWorkflowWithIdempotencyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "workflow processes order correctly and maintains exact random number" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    travel_to Time.current do
      assert_difference -> { DurableFlow::StepExecution.count } => 2 do
        OrderProcessingWorkflowWithIdempotency.run(event: event, account: account)
        perform_enqueued_jobs
      end

      random_number_step = DurableFlow::StepExecution.find_by(name: 'generate_random_number')
      assert_not_nil random_number_step
      assert_equal 'completed', random_number_step.status
      initial_random_number = random_number_step.output

      wait_step = DurableFlow::StepExecution.find_by(name: 'some_time')
      assert_not_nil wait_step
      assert_equal 'sleeping', wait_step.status

      # Simulate time passing
      travel 1.hour

      assert_difference -> { DurableFlow::StepExecution.count } => 1 do
        perform_enqueued_jobs
      end

      wait_step.reload
      assert_equal 'completed', wait_step.status

      # Ensure the random number is exactly the same after all steps
      assert_equal initial_random_number, random_number_step.reload.output
    end
  end
end
