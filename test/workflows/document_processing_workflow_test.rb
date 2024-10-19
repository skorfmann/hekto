require 'test_helper'

class DocumentProcessingWorkflowTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures 'durable_flow/events', :accounts

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "processes the workflow and returns normalized rows" do
    event = durable_flow_events(:one)
    document = event.subject
    document.file = active_storage_blobs(:invoice_pdf_blob)
    document.save!
    account = accounts(:one)

    workflow = nil
    assert_enqueued_with(job: WorkflowJob) do
      workflow = DocumentProcessingWorkflow.run(event: event, account: account)
    end

    assert_instance_of DurableFlow::WorkflowInstance, workflow

    assert_difference -> { DurableFlow::StepExecution.count } => 2 do
      perform_enqueued_jobs
    end

    result = DurableFlow::WorkflowInstance.last.output

    expected_result = [
      { "name" => "John Doe", "email" => "john@example.com" }
    ]
    assert_equal expected_result, result
  end
end