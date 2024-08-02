class DocumentProcessingWorkflow
  include Statesman::Machine

  state :pending, initial: true
  state :processing
  state :summarizing
  state :completed
  state :failed

  transition from: :pending,     to: %i[processing failed]
  transition from: :processing,  to: %i[summarizing failed]
  transition from: :summarizing, to: %i[completed failed]

  guard_transition(to: :processing) do |document|
    document.file.attached? && document.file.content_type.in?(['application/pdf', 'image/jpeg', 'image/png'])
  end

  after_transition(to: :processing) do |document, transition|
    DocumentProcessingJob.perform_later(document.id)
  end

  after_transition(to: :summarizing) do |document, transition|
    DocumentSummaryJob.perform_later(document.id)
  end

  after_transition(to: :completed) do |document, transition|
    Rails.logger.info "Document processing completed for document #{document.id}"
    # You might want to add a notification service here
    # NotificationService.processing_complete(document).deliver
  end

  after_transition(to: :failed) do |document, transition|
    Rails.logger.error "Document processing failed for document #{document.id}"
    # You might want to add error handling or notification here
  end
end
