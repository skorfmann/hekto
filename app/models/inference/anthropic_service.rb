require 'bigdecimal'
require 'httparty'

module Inference
  class AnthropicService < AiService
    COSTS_PER_1K_TOKENS = {
      'claude-3-5-sonnet' => { input: BigDecimal('0.0015'), output: BigDecimal('0.002') },
      'claude-3-5-sonnet-20240620' => { input: BigDecimal('0.0015'), output: BigDecimal('0.002') },
      'claude-3-haiku' => { input: BigDecimal('0.0015'), output: BigDecimal('0.002') },
      'claude-3-opus' => { input: BigDecimal('0.0015'), output: BigDecimal('0.002') },
      'claude-3-5-sonnet-20240229' => { input: BigDecimal('0.0015'), output: BigDecimal('0.002') },
    }

    def stream(prompt:, model:)
      client = Anthropic::Client.new
      provider_stream = client.messages(
        parameters: {
          model: model,
          messages: [{ role: "user", content: [prompt] }],
          stream: true,
          max_tokens: 4096 # You may want to adjust this value
        }
      ) { |chunk| yield chunk if block_given? }
      AIStream.new(provider_stream)
    end

    def complete(prompt:, model:)
      url = 'https://api.anthropic.com/v1/messages'
      headers = {
        'Content-Type' => 'application/json',
        'X-Api-Key' => Rails.application.credentials.dig(:anthropic, :api_key),
        'anthropic-version' => '2023-06-01'
      }
      body = {
        model: model,
        messages: [{ role: "user", content: prompt }],
        max_tokens: 4096
      }

      response = HTTParty.post(url, headers: headers, body: body.to_json)

      if response.success?
        data = JSON.parse(response.body)
        content = data.dig("content", 0, "text")
        input_tokens = BigDecimal(data.dig("usage", "input_tokens").to_s)
        output_tokens = BigDecimal(data.dig("usage", "output_tokens").to_s)

        input_cost = (input_tokens / 1000) * COSTS_PER_1K_TOKENS[model][:input]
        output_cost = (output_tokens / 1000) * COSTS_PER_1K_TOKENS[model][:output]
        total_cost = input_cost + output_cost

        OpenStruct.new(
          text: content,
          input_tokens: input_tokens.to_i,
          output_tokens: output_tokens.to_i,
          cost_per_1000_input_tokens: COSTS_PER_1K_TOKENS[model][:input].to_f,
          cost_per_1000_output_tokens: COSTS_PER_1K_TOKENS[model][:output].to_f,
          total_cost: total_cost.round(10).to_f
        )
      else
        raise "API request failed: #{response.code} - #{response.body}"
      end
    end
  end
end
