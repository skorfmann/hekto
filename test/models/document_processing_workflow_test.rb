require 'test_helper'

class DocumentProcessingWorkflowTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @document = documents(:one)
    @event = durable_flow_events(:one)
    @event.subject = @document
    @event.save!
    @workflow = DocumentProcessingWorkflow.run(event: @event, account: @document.account)
  end
end
