module Inference
  class Prompt
    class << self
      attr_reader :model_name, :provider_name

      def model(name)
        @model_name = name
      end

      def provider(name)
        @provider_name = name
      end
    end

    private

    def render_text(locals: {}, account:, user:)
      template_path = template_file_path
      template = ERB.new(File.read(template_path))
      context = OpenStruct.new(locals.merge(account: account, user: user))
      rendered_prompt = template.result(context.instance_eval { binding })

      Inference.create_text(
        account: account,
        user: user,
        prompt: rendered_prompt,
        model: self.class.model_name,
        provider: self.class.provider_name
      ).response
    end

    def template_file_path
      # class_name = self.class.name.demodulize.underscore
      method_name = caller_locations(2, 1)[0].label
      locale = I18n.locale
      Rails.root.join('app', 'prompts', "#{method_name}.#{locale}.erb")
    end
  end
end
