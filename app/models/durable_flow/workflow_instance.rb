# == Schema Information
#
# Table name: durable_flow_workflow_instances
#
#  id         :bigint           not null, primary key
#  account_id :bigint           not null
#  event_id   :bigint           not null
#  input      :jsonb
#  output     :jsonb
#  state      :jsonb
#  status     :integer          default("pending")
#  payload    :jsonb
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DurableFlow::WorkflowInstance < ApplicationRecord
  belongs_to :account
  has_many :step_executions, class_name: "DurableFlow::StepExecution"
  belongs_to :event, class_name: "DurableFlow::Event"

  enum :status, %i[pending running completed failed cancelled]
end
