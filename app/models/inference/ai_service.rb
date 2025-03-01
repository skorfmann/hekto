module Inference
  class AiService
    class << self
      def for(provider)
        case provider.to_sym
        when :openai
          OpenAIService.new
        when :anthropic
          AnthropicService.new
        else
          raise ArgumentError, "Unsupported AI provider: #{provider}"
        end
      end
    end

    # Abstract methods to be implemented by subclasses
    def stream(prompt:, model:)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def complete(prompt:, model:)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def create_object(prompt:, model:, object_definition:)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
