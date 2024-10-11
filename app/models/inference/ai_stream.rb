module Inference
  class AIStream
    attr_reader :provider_stream

    def initialize(provider_stream)
      @provider_stream = provider_stream
      @data_handlers = []
      @error_handlers = []
      @complete_handlers = []
    end

    def on_data(&block)
      @data_handlers << block
    end

    def on_error(&block)
      @error_handlers << block
    end

    def on_complete(&block)
      @complete_handlers << block
    end

    def start
      provider_stream.on(:data) { |chunk| @data_handlers.each { |handler| handler.call(chunk) } }
      provider_stream.on(:error) { |error| @error_handlers.each { |handler| handler.call(error) } }
      provider_stream.on(:end) do |stats|
        @complete_handlers.each { |handler| handler.call(stats) }
      end
      provider_stream.start
    end
  end
end
