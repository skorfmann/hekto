module Inference
  class OpenAIService < AIService
    def stream(prompt:, model:)
      client = OpenAI::Client.new
      provider_stream = client.chat(
        parameters: {
          model: model,
          messages: [{ role: "user", content: prompt }],
          stream: proc do |chunk|
            # Process chunk
          end
        }
      )
      AIStream.new(provider_stream)
    end

    def complete(prompt:, model:)
      client = OpenAI::Client.new
      response = client.chat(
        parameters: {
          model: model,
          messages: [{ role: "user", content: prompt }]
        }
      )
      response.dig("choices", 0, "message", "content")
    end
  end
end