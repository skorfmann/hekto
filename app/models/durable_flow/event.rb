# == Schema Information
#
# Table name: durable_flow_events
#
#  id           :bigint           not null, primary key
#  account_id   :bigint           not null
#  user_id      :bigint
#  name         :string
#  payload      :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_type :string
#  subject_id   :bigint
#
class DurableFlow::Event < ApplicationRecord
  belongs_to :account
  belongs_to :user, optional: true
  has_many :workflow_instances, class_name: "DurableFlow::WorkflowInstance"
  belongs_to :subject, polymorphic: true, optional: true
end
