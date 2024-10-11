class DurableFlow::StepExecution < ApplicationRecord
  belongs_to :account
  belongs_to :workflow_instance, class_name: 'DurableFlow::WorkflowInstance'
end
