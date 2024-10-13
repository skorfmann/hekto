require "administrate/base_dashboard"

module Inference
  class InferenceDashboard < Administrate::BaseDashboard
    ATTRIBUTE_TYPES = {
      id: Field::Number,
      account: Field::BelongsTo,
      user: Field::BelongsTo,
      prompt: Field::Text,
      response: Field::Text,
      input_tokens: Field::Number,
      output_tokens: Field::Number,
      model: Field::String,
      provider: Field::String,
      cost_per_1000_input_tokens: Field::Number.with_options(decimals: 16),
      cost_per_1000_output_tokens: Field::Number.with_options(decimals: 16),
      subject: Field::Polymorphic.with_options(classes: [Document]),
      status: Field::Select.with_options(choices: Inference.statuses.keys),
      object_definition: Field::Text,
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :id,
      :account,
      :user,
      :model,
      :provider,
      :status,
      :created_at
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :id,
      :account,
      :user,
      :prompt,
      :response,
      :input_tokens,
      :output_tokens,
      :model,
      :provider,
      :cost_per_1000_input_tokens,
      :cost_per_1000_output_tokens,
      :subject,
      :status,
      :object_definition,
      :created_at,
      :updated_at
    ].freeze

    FORM_ATTRIBUTES = [
      :account,
      :user,
      :prompt,
      :model,
      :provider,
      :subject,
      :status,
      :object_definition
    ].freeze

    # Overwrite this method to customize how inferences are displayed
    # across all pages of the admin dashboard.
    #
    # def display_resource(inference)
    #   "Inference ##{inference.id}"
    # end
  end
end

