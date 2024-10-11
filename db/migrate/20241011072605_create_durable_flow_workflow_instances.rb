class CreateDurableFlowWorkflowInstances < ActiveRecord::Migration[8.0]
  def change
    create_table :durable_flow_workflow_instances do |t|
      t.references :account, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: { to_table: :durable_flow_events }
      t.jsonb :input
      t.jsonb :output
      t.jsonb :state
      t.string :status
      t.jsonb :payload
      t.string :name

      t.timestamps
    end
  end
end
