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
end
