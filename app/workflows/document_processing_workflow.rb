class DocumentProcessingWorkflow < DurableFlow::Workflow
  def execute(document_id)
    document = Document.find(document_id)

    summary = step :create_summary do
      DocumentProcessingWorkflowPrompt.new.create_summary(document)
    end

    step :update_document do
      document.update(content: summary)
    end
  end
end
