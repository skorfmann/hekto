require "administrate/base_dashboard"

class DurableFlow::WorkflowInstanceDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    event: Field::BelongsTo.with_options(class_name: "DurableFlow::Event"),
    input: Field::String.with_options(formatter: :json),
    output: Field::String.with_options(formatter: :json),
    state: Field::String.with_options(formatter: :json),
    status: Field::Select.with_options(choices: DurableFlow::WorkflowInstance.statuses.keys),
    payload: Field::String.with_options(formatter: :json),
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    step_executions: Field::HasMany.with_options(class_name: "DurableFlow::StepExecution")
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :account,
    :name,
    :status,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :account,
    :event,
    :name,
    :status,
    :input,
    :output,
    :state,
    :payload,
    :created_at,
    :updated_at,
    :step_executions
  ].freeze

  FORM_ATTRIBUTES = [
    :account,
    :event,
    :name,
    :status,
    :input,
    :output,
    :state,
    :payload
  ].freeze

  # Overwrite this method to customize how workflow instances are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(workflow_instance)
  #   "DurableFlow::WorkflowInstance ##{workflow_instance.id}"
  # end
end
