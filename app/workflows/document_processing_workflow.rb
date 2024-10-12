class DocumentProcessingWorkflow < DurableFlow::Workflow
  subscribe_to :document_changed

  def execute(event)
    document = event.subject

    summary = step :create_summary do
      DocumentProcessingWorkflowPrompt.new.create_summary(document)
    end

    step :update_document do
      document.update(content: summary)
    end
  end
end
