class WorkflowJob < ApplicationJob
  queue_as :default

  def perform(workflow_instance_id)
    workflow_instance = DurableFlow::WorkflowInstance.find(workflow_instance_id)
    workflow_class = workflow_instance.name.constantize
    workflow = workflow_class.new(workflow_instance)

    catch(:pause_workflow) do
      result = workflow.execute(workflow.event)
      # If we reach here, the workflow completed without pausing
      persist_result(workflow_instance, result)
      return
    end

    # If we reach here, :pause_workflow was thrown
    # The workflow's sleep_for method will have scheduled the next run
  end

  private

  def persist_result(workflow_instance, result)
    workflow_instance.update(output: result)
  rescue => e
    Rails.logger.error("Failed to persist workflow result: #{e.message}")
  end
end