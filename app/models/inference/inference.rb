# == Schema Information
#
# Table name: inferences
#
#  id                          :bigint           not null, primary key
#  account_id                  :bigint
#  user_id                     :bigint
#  prompt                      :text
#  response                    :text
#  input_tokens                :integer
#  output_tokens               :integer
#  model                       :string
#  provider                    :string
#  cost_per_1000_input_tokens  :decimal(20, 16)
#  cost_per_1000_output_tokens :decimal(20, 16)
#  subject_type                :string
#  subject_id                  :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  status                      :integer
#  object_definition           :text
#
module Inference
  class Inference < ApplicationRecord
    belongs_to :account
    belongs_to :user
    belongs_to :subject, polymorphic: true, optional: true

    validates :prompt, presence: true
    validates :model, presence: true
    validates :provider, presence: true
    enum :status, %i[pending inferencing completed failed]

    def self.create_stream(account:, user:, prompt:, model:, provider:, subject: nil, &block)
      inference = create!(
        account: account,
        user: user,
        prompt: prompt,
        model: model,
        provider: provider,
        subject: subject
      )

      ai_service = AiService.for(provider)
      stream = ai_service.stream(prompt: prompt, model: model)

      stream.on_data do |chunk|
        inference.update(response: inference.response.to_s + chunk)
        block.call(chunk) if block_given?
      end

      stream.on_complete do |stats|
        inference.update(
          input_tokens: stats[:input_tokens],
          output_tokens: stats[:output_tokens],
          cost_per_1000_input_tokens: stats[:cost_per_1000_input_tokens],
          cost_per_1000_output_tokens: stats[:cost_per_1000_output_tokens]
        )
      end

      stream
    end

    def self.create_text(account:, user:, prompt:, model:, provider:, subject: nil)
      inference = create!(
        account: account,
        user: user,
        prompt: prompt,
        model: model,
        provider: provider,
        subject: subject,
        status: :inferencing
      )

      ai_service = AiService.for(provider)
      result = ai_service.complete(prompt: prompt, model: model)

      inference.update(
        response: result.text,
        input_tokens: result.input_tokens,
        output_tokens: result.output_tokens,
        cost_per_1000_input_tokens: result.cost_per_1000_input_tokens,
        cost_per_1000_output_tokens: result.cost_per_1000_output_tokens,
        status: :completed
      )

      inference
    rescue StandardError => e
      inference.update(status: :failed)
      raise e
    end

    def total_cost
      input_cost = (input_tokens.to_f / 1000) * cost_per_1000_input_tokens
      output_cost = (output_tokens.to_f / 1000) * cost_per_1000_output_tokens
      input_cost + output_cost
    end

    def self.create_object(account:, user:, prompt:, model:, provider:, object_definition:, subject: nil)
      inference = create!(
        account: account,
        user: user,
        prompt: prompt,
        model: model,
        provider: provider,
        object_definition: object_definition,
        subject: subject,
        status: :inferencing
      )

      ai_service = AiService.for(provider)
      result = ai_service.create_object(prompt: prompt, model: model, object_definition: object_definition)

      inference.update(
        response: result.object.to_json,
        input_tokens: result.input_tokens,
        output_tokens: result.output_tokens,
        cost_per_1000_input_tokens: result.cost_per_1000_input_tokens,
        cost_per_1000_output_tokens: result.cost_per_1000_output_tokens,
        status: :completed
      )

      inference
    rescue StandardError => e
      inference.update(status: :failed)
      raise e
    end
  end
end
