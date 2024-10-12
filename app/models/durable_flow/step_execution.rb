# == Schema Information
#
# Table name: durable_flow_step_executions
#
#  id                   :bigint           not null, primary key
#  account_id           :bigint           not null
#  workflow_instance_id :bigint           not null
#  name                 :string
#  payload              :jsonb
#  input                :jsonb
#  output               :jsonb
#  error                :jsonb
#  status               :integer          default("pending")
#  sleep_until          :datetime
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class DurableFlow::StepExecution < ApplicationRecord
  belongs_to :account
  belongs_to :workflow_instance, class_name: 'DurableFlow::WorkflowInstance'

  enum :status, %i[pending running sleeping completed failed cancelled]
end
