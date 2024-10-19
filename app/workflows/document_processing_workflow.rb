class DocumentProcessingWorkflow < DurableFlow::Workflow
  subscribe_to :document_new

  def execute(event)
    document = event.subject

    if document.file.content_type == 'application/pdf'
      step :extract_images_from_pdf do
        extract_images(document)
      end
    else
      # convenience step to attach the image to the document
      step :extract_images_from_image do
        document.images.attach(
          io: StringIO.new(document.file.download),
          filename: document.file.filename,
          content_type: document.file.content_type
        )
      end
    end

    metadata = step :extract_metadata do
      DocumentProcessingWorkflowPrompt.new.extract_metadata(document)
    end

    step :update_document_metadata do
      document.update(metadata:)
    end

    summary = step :create_summary do
      DocumentProcessingWorkflowPrompt.new.create_summary(document)
    end

    step :update_document do
      document.update(content: summary)
    end
  end

  private

  def extract_images(document)
    Tempfile.create(['temp_pdf', '.pdf']) do |temp_file|
      temp_file.binmode
      temp_file.write(document.file.download)
      temp_file.flush

      # Load the PDF using libvips at 2x scale
      pdf = ::Vips::Image.new_from_file(temp_file.path, access: :sequential, scale: 2)
      n_pages = pdf.get('n-pages')

      n_pages.times do |page_number|
        # Extract each page as an image
        image = pdf.crop(0, page_number * pdf.height, pdf.width, pdf.height)
        # Convert the image to PNG format
        png_data = image.write_to_buffer('.png')

        # Attach the image directly from the buffer
        document.images.attach(
          io: StringIO.new(png_data),
          filename: "page_#{page_number + 1}.png",
          content_type: 'image/png'
        )
      end
    end

    document.save
  end
end
