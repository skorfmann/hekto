require "administrate/base_dashboard"

class DurableFlow::EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    user: Field::BelongsTo,
    name: Field::String,
    payload: Field::String.with_options(formatter: :json),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    workflow_instances: Field::HasMany.with_options(class_name: "DurableFlow::WorkflowInstance"),
    subject: Field::Polymorphic.with_options(types: ['Document'])
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :account,
    :name,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :account,
    :user,
    :name,
    :payload,
    :created_at,
    :updated_at,
    :workflow_instances,
    :subject
  ].freeze

  FORM_ATTRIBUTES = [
    :account,
    :user,
    :name,
    :payload,
    :subject
  ].freeze

  # Overwrite this method to customize how events are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(event)
  #   "DurableFlow::Event ##{event.id}"
  # end
end

