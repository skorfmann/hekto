module Inference
  class OpenAIService < AiService
    COSTS_PER_1K_TOKENS = {
      'gpt-3.5-turbo' => { input: 0.0015, output: 0.002 },
      'gpt-4' => { input: 0.03, output: 0.06 },
      'gpt-4-32k' => { input: 0.06, output: 0.12 }
    }

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