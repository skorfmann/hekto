require 'base64'

class DocumentProcessingJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    Rails.logger.info "Starting DocumentProcessingJob for document_id: #{document_id}"
    document = Document.find(document_id)
    Rails.logger.info "Document found: #{document.inspect}"

    # Configure Anthropic client
    Anthropic.configure do |config|
      config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
    end
    Rails.logger.info 'Anthropic client configured'

    # Read and encode the file content
    file_content = document.file.download
    encoded_content = Base64.strict_encode64(file_content)
    Rails.logger.info "File content encoded, size: #{encoded_content.bytesize} bytes"

    # Prepare the message for Claude
    message = [
      {
        type: 'image',
        source: {
          type: 'base64',
          media_type: document.file.content_type,
          data: encoded_content
        }
      },
      {
        type: 'text',
        text: <<~PROMPT
          Extract receipt data from the above image and format it as JSON according to the following type definition:

          type Receipt = {
            merchant: {
              name: string;
              address?: string;
            };
            items: Array<{
              name: string;
              quantity: number;
              price: {
                amount: number;
                currency: string; // ISO 4217 currency code
              };
            }>;
            total: {
              net?: {
                amount: number;
                currency: string;
              };
              tax?: {
                amount: number;
                currency: string;
              };
              gross: {
                amount: number;
                currency: string;
              };
            };
            payment: {
              method: string;
              amount: {
                amount: number;
                currency: string;
              };
            };
            date: string; // ISO 8601 date format (YYYY-MM-DD)
            time?: string; // Time in HH:MM:SS format
            receipt_number?: string;
          };

          Ensure all data is correctly formatted according to this structure.
        PROMPT
      }
    ]
    Rails.logger.info 'Message prepared for Claude'

    Rails.logger.info 'Sending request to Claude'
    response = Anthropic::Client.new.messages(
      parameters: {
        model: Rails.application.credentials.dig(:anthropic, :model) || 'claude-3-5-sonnet-20240620',
        messages: [
          { role: 'user', content: message },
          { role: 'assistant', content: '{' }
        ],
        max_tokens: 1000
      }
    )
    Rails.logger.info 'Received response from Claude'

    puts "Claude response: #{response.inspect}"

    # Extract the response content
    extracted_data = response['content'][0]['text']
    Rails.logger.info "Extracted data: #{extracted_data}"

    # Update the document with extracted data as metadata
    document.update(metadata: "{#{extracted_data}")
    Rails.logger.info 'Document updated with extracted data'

    Rails.logger.info "DocumentProcessingJob completed successfully for document_id: #{document_id}"
  rescue StandardError => e
    Rails.logger.error "Error processing document #{document_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise # Re-raise the exception
  end
end
