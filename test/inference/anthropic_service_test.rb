require 'test_helper'

class InferenceAnthropicServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "anthropic service" do
    VCR.use_cassette("anthropic_service") do
      service = Inference::AnthropicService.new
      begin
        result = service.complete(prompt: "Hello, how are you?", model: "claude-3-5-sonnet-20240620")
        assert_match /Hello.*AI.*assist you/, result.text
        assert_instance_of OpenStruct, result
        assert_equal 13, result.input_tokens
        assert_equal 35, result.output_tokens
        assert_equal 0.0015, result.cost_per_1000_input_tokens
        assert_equal 0.002, result.cost_per_1000_output_tokens
        assert_equal 0.0000895, result.total_cost
      rescue => e
        puts "Error details: #{e}"
        raise
      end
    end
  end
end
