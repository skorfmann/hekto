class DocumentSummaryJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    Rails.logger.info "Starting DocumentSummaryJob for document_id: #{document_id}"
    document = Document.find(document_id)
    Rails.logger.info "Document found: #{document.inspect}"

    # Configure Anthropic client
    Anthropic.configure do |config|
      config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
    end
    Rails.logger.info 'Anthropic client configured'

    create_summary(document)

    Rails.logger.info "DocumentSummaryJob completed successfully for document_id: #{document_id}"
  rescue StandardError => e
    Rails.logger.error "Error summarizing document #{document_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise # Re-raise the exception
  end

  private

  def create_summary(document)
    prompt = {
      type: 'text',
      text: "
        #{document.metadata}

        erstelle eine kurze, einzeilige zusammenfassung des Inhalts des Dokuments zur leichteren Erinnerung.
        z.b. Lunch bei Trattoria in Berlin, 1. Mai 2024, 12:00 Uhr, 2 Personen, 20€"
    }

    response = Anthropic::Client.new.messages(
      parameters: {
        model: Rails.application.credentials.dig(:anthropic, :model) || 'claude-3-5-sonnet-20240620',
        messages: [
          { role: 'user', content: [prompt] }
        ],
        max_tokens: 100
      }
    )

    summary = response['content'][0]['text'].strip
    document.update(content: summary)
  end
end
