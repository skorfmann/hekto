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
#  status               :string
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require "test_helper"

class DurableFlow::StepExecutionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
