require 'test_helper'

class InferenceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:one)
    @user = users(:one)
    @prompt = "What's the meaning of life?"
    @model = "claude-3-5-sonnet-20240620"
    @provider = "anthropic"
  end

  test "create_text returns valid result" do
    VCR.use_cassette("anthropic_service_all_params") do

      assert_difference 'Inference::Inference.count', 1 do
        result = Inference::Inference.create_text(
          account: @account,
          user: @user,
          prompt: @prompt,
          model: @model,
          provider: @provider
        )

        assert_instance_of Inference::Inference, result
        assert_equal @account, result.account
        assert_equal @user, result.user
        assert_equal @prompt, result.prompt
        assert_equal @model, result.model
        assert_equal @provider, result.provider
      end
    end
  end

  test "create_text persists LLM response data" do
    VCR.use_cassette("anthropic_service_llm_response") do
      result = Inference::Inference.create_text(
        account: @account,
        user: @user,
        prompt: @prompt,
        model: @model,
        provider: @provider
      )

      # Verify the persisted data matches the result
      persisted_inference = Inference::Inference.find(result.id)
      assert_match /The meaning of life is a profound philosophical question/, persisted_inference.response
      assert_equal 14, persisted_inference.input_tokens
      assert_equal 209, persisted_inference.output_tokens
      assert_equal Inference::AnthropicService::COSTS_PER_1K_TOKENS[@model][:input], persisted_inference.cost_per_1000_input_tokens
      assert_equal Inference::AnthropicService::COSTS_PER_1K_TOKENS[@model][:output], persisted_inference.cost_per_1000_output_tokens
      assert_equal 'completed', persisted_inference.status
    end
  end

  test "create_object persists structured data" do
    VCR.use_cassette("inference_create_object") do
      object_definition = {
        "data": {
          "type": "person",
          "attributes": {
            "name": "string",
            "age": "integer",
            "occupation": "string"
          }
        }
      }.to_json

      result = Inference::Inference.create_object(
        account: @account,
        user: @user,
        prompt: "John Doe is a 35-year-old software engineer.",
        model: @model,
        provider: @provider,
        object_definition: object_definition
      )

      assert_instance_of Inference::Inference, result
      assert_equal @account, result.account
      assert_equal @user, result.user
      assert_equal @model, result.model
      assert_equal @provider, result.provider
      assert_equal 'completed', result.status

      parsed_response = JSON.parse(result.response)
      assert_equal "person", parsed_response.dig("data", "type")
      assert_equal "John Doe", parsed_response.dig("data", "attributes", "name")
      assert_equal 35, parsed_response.dig("data", "attributes", "age")
      assert_equal "software engineer", parsed_response.dig("data", "attributes", "occupation")

      assert result.input_tokens.positive?
      assert result.output_tokens.positive?
      assert_equal Inference::AnthropicService::COSTS_PER_1K_TOKENS[@model][:input], result.cost_per_1000_input_tokens
      assert_equal Inference::AnthropicService::COSTS_PER_1K_TOKENS[@model][:output], result.cost_per_1000_output_tokens
    end
  end
end
