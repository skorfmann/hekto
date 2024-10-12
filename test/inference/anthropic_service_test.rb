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

  test "create_object with JSON:API object definition" do
    VCR.use_cassette("anthropic_service_create_object") do
      service = Inference::AnthropicService.new
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

      prompt = "John Doe is a 35-year-old software engineer."
      model = "claude-3-5-sonnet-20240620"

      result = service.create_object(prompt: prompt, model: model, object_definition: object_definition)

      assert_instance_of OpenStruct, result
      assert_instance_of Hash, result.object
      assert_equal "person", result.object.dig("data", "type")
      assert_equal "John Doe", result.object.dig("data", "attributes", "name")
      assert_equal 35, result.object.dig("data", "attributes", "age")
      assert_equal "software engineer", result.object.dig("data", "attributes", "occupation")

      assert result.input_tokens.positive?
      assert result.output_tokens.positive?
      assert_equal 0.0015, result.cost_per_1000_input_tokens
      assert_equal 0.002, result.cost_per_1000_output_tokens
      assert result.total_cost.positive?
    end
  end
end
