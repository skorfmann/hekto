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

    def render_text(locals: {}, account:, user:, subject:)
      template_path = template_file_path
      template = ERB.new(File.read(template_path))
      context = OpenStruct.new(locals.merge(account: account, user: user))
      rendered_prompt = template.result(context.instance_eval { binding })

      Inference.create_text(
        account: account,
        user: user,
        prompt: rendered_prompt,
        model: self.class.model_name,
        provider: self.class.provider_name,
        subject: subject
      ).response
    end

    def render_json(locals: {}, account:, user:, subject:)
      template_path = template_file_path('json.jbuilder')
      schema_path = template_file_path('json.schema')
      context = OpenStruct.new(locals.merge(account: account, user: user))

      rendered_prompt = Jbuilder.new do |json|
        json.instance_eval do
          # Make context methods available as local methods
          context.methods(false).each do |method|
            define_singleton_method(method) { context.send(method) }
          end

          # Evaluate the template in the context of the Jbuilder instance
          eval(File.read(template_path))
        end
      end.attributes!

      schema = JSON.parse(File.read(schema_path))

      Inference.create_object(
        account: account,
        user: user,
        prompt: rendered_prompt.to_json,
        model: self.class.model_name,
        provider: self.class.provider_name,
        subject: subject,
        object_definition: schema
      ).response
    end

    def template_file_path(format = 'erb')
      method_name = caller_locations(2, 1)[0].label
      locale = I18n.locale

      localized_path = Rails.root.join('app', 'prompts', "#{method_name}.#{locale}.#{format}")
      non_localized_path = Rails.root.join('app', 'prompts', "#{method_name}.#{format}")

      File.exist?(localized_path) ? localized_path : non_localized_path
    end
  end
end
