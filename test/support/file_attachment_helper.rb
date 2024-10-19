module FileAttachmentHelper
  def attach_file_to_document(document, file_path)
    full_path = Rails.root.join('test', 'files', file_path)
    file = File.open(full_path)
    document.file.attach(io: file, filename: File.basename(file_path))
  end

  def attach_images_to_document(document, image_paths)
    image_paths.each do |image_path|
      full_path = Rails.root.join('test', 'files', image_path)
      file = File.open(full_path)
      document.images.attach(io: file, filename: File.basename(image_path))
    end
  end
end
