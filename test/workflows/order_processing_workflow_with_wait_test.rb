require 'test_helper'

class OrderProcessingWorkflowWithTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "workflow waits for specified duration before continuing" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    travel_to Time.current do
      assert_difference -> { DurableFlow::StepExecution.count } => 2 do
        OrderProcessingWorkflowWithWait.run(event: event, account: account)
        perform_enqueued_jobs
      end

      wait_step_execution = DurableFlow::StepExecution.find_by(name: 'the_end_of_time')
      assert_not_nil wait_step_execution
      assert_equal 'sleeping', wait_step_execution.status

      # Simulate time passing
      travel 1.hour

      assert_difference -> { DurableFlow::StepExecution.count } => 1 do
        perform_enqueued_jobs
      end

      wait_step_execution.reload
      assert_equal 'completed', wait_step_execution.status

      final_step_execution = DurableFlow::StepExecution.last
      assert_equal 'completed', final_step_execution.status
      assert_equal [{ "name" => "John Doe", "email" => "john@example.com" }], final_step_execution.output
    end
  end

  test "workflow does not continue when wait time hasn't passed" do
    event = durable_flow_events(:one)
    account = accounts(:one)

    travel_to Time.current do
      assert_difference -> { DurableFlow::StepExecution.count } => 2 do
        OrderProcessingWorkflowWithWait.run(event: event, account: account)
        perform_enqueued_jobs
      end

      wait_step_execution = DurableFlow::StepExecution.find_by(name: 'the_end_of_time')
      assert_not_nil wait_step_execution
      assert_equal 'sleeping', wait_step_execution.status

      # Simulate time passing, but less than the wait duration
      travel 30.minutes

      assert_no_difference -> { DurableFlow::StepExecution.count } do
        perform_enqueued_jobs
      end

      wait_step_execution.reload
      assert_equal 'sleeping', wait_step_execution.status

      assert_nil DurableFlow::StepExecution.find_by(name: 'final_step')
    end
  end
end