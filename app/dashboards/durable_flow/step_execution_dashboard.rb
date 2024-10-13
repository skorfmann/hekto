require "administrate/base_dashboard"

class DurableFlow::StepExecutionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    workflow_instance: Field::BelongsTo.with_options(class_name: 'DurableFlow::WorkflowInstance'),
    name: Field::String,
    payload: Field::String.with_options(formatter: :json),
    input: Field::String.with_options(formatter: :json),
    output: Field::String.with_options(formatter: :json),
    error: Field::String.with_options(formatter: :json),
    status: Field::Select.with_options(choices: DurableFlow::StepExecution.statuses.keys),
    sleep_until: Field::DateTime,
    type: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :account,
    :workflow_instance,
    :name,
    :status,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :account,
    :workflow_instance,
    :name,
    :status,
    :payload,
    :input,
    :output,
    :error,
    :sleep_until,
    :type,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :account,
    :workflow_instance,
    :name,
    :status,
    :payload,
    :input,
    :output,
    :error,
    :sleep_until,
    :type
  ].freeze

  # Overwrite this method to customize how step executions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(step_execution)
  #   "DurableFlow::StepExecution ##{step_execution.id}"
  # end
end

