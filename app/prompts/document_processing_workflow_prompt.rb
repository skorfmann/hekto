class DocumentProcessingWorkflowPrompt < Inference::Prompt
  model 'claude-3-5-sonnet-20240620'
  provider 'anthropic'

  def create_summary(document)
    render_text locals: { document: document }, account: document.account, user: document.owner
  end
end
