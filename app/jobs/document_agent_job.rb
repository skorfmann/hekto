class DocumentAgentJob < ApplicationJob
  queue_as :anthropic

  def perform(document_id)
    document = Document.find(document_id)
    document.update(metadata: {})
  end
end
