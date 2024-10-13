json.messages do
  json.array! [
    {
      role: 'human',
      content: document.encoded_images.map do |encoded_image|
        {
          type: 'image',
          source: {
            type: 'base64',
            media_type: encoded_image[:mime_type],
            data: encoded_image[:content]
          }
        }
      end + [
        {
          type: 'text',
          text: <<~PROMPT
            Today is #{Date.today}. It's a German receipt.
          PROMPT
        }
      ]
    }
  ]
end
