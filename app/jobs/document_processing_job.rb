require 'base64'
require 'pdf-reader'
require 'vips'
require 'fileutils'

class DocumentProcessingJob < ApplicationJob
  queue_as :anthropic

  def perform(document_id)
    Rails.logger.info "Starting DocumentProcessingJob for document_id: #{document_id}"
    document = Document.find(document_id)
    Rails.logger.info "Document found: #{document.inspect}"

    # Configure Anthropic client
    Anthropic.configure do |config|
      config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
    end
    Rails.logger.info 'Anthropic client configured'

    # Process file content based on file type
    if document.file.content_type == 'application/pdf'
      process_pdf(document)
    else
      process_image(document)
    end

    Rails.logger.info "DocumentProcessingJob completed successfully for document_id: #{document_id}"
  rescue StandardError => e
    Rails.logger.error "Error processing document #{document_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise # Re-raise the exception
  end

  private

  def process_pdf(document)
    pdf_images = []

    # Create a temporary file to store the PDF content
    Tempfile.create(['temp_pdf', '.pdf']) do |temp_file|
      temp_file.binmode
      temp_file.write(document.file.download)
      temp_file.flush

      # Load the PDF using libvips at 2x scale
      pdf = Vips::Image.new_from_file(temp_file.path, access: :sequential, scale: 2)
      # Get the number of pages
      n_pages = pdf.get('n-pages')

      n_pages.times do |page_number|
        # Extract each page as an image
        image = pdf.crop(0, page_number * pdf.height, pdf.width, pdf.height)

        # Create tmp/foo directory if it doesn't exist
        debug_dir = Rails.root.join('tmp', 'foo')
        FileUtils.mkdir_p(debug_dir)

        # Save the image for debugging
        debug_path = debug_dir.join("page_#{page_number + 1}.png")
        image.write_to_file(debug_path.to_s)

        Rails.logger.info "Saved debug image: #{debug_path}"

        # Convert the image to PNG format and encode as base64
        png_data = image.write_to_buffer('.png')
        pdf_images << Base64.strict_encode64(png_data)
      end
    end

    process_images(pdf_images, document, 'image/png')
  end

  def process_image(document)
    encoded_content = Base64.strict_encode64(document.file.download)
    process_images([encoded_content], document, document.file.content_type)
  end

  def process_images(encoded_images, document, mime_type)
    content = encoded_images.map do |encoded_content|
      {
        type: 'image',
        source: {
          type: 'base64',
          media_type: mime_type,
          data: encoded_content
        }
      }
    end

    content << {
      type: 'text',
      text: <<~PROMPT
        Extract receipt data from the above image(s) and format it as JSON according to the following type definition:

        type Receipt = {
          merchant: {
            name: string;
            address?: string;
            phone?: string;
            email?: string;
            website?: string;
            vatNumber?: string;
            taxNumber?: string;
          };
          items: Array<{
            name: string;
            quantity: number;
            price: {
              amount: number;
              currency: string; // ISO 4217 currency code
            };
            taxRate: number; // VAT tax rate as a decimal (e.g., 0.20 for 20%)
            taxAmount: {
              amount: number;
              currency: string;
            };
          }>;
          total: {
            net: {
              amount: number;
              currency: string;
            };
            tax: Array<{
              rate: number;
              amount: {
                amount: number;
                currency: string;
              };
            }>;
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
        Today is #{Date.today}. It's a German receipt.
      PROMPT
    }

    response = Anthropic::Client.new.messages(
      parameters: {
        model: Rails.application.credentials.dig(:anthropic, :model) || 'claude-3-5-sonnet-20240620',
        messages: [
          { role: 'user', content: },
          { role: 'assistant', content: '{' }
        ],
        max_tokens: 4000
      }
    )

    result = response['content'][0]['text']
    parsed_result = JSON.parse("{#{result}")
    document.update(metadata: parsed_result)
  end
end
