class CreateDurableFlowStepExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :durable_flow_step_executions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :workflow_instance, null: false, foreign_key: { to_table: :durable_flow_workflow_instances }
      t.string :name
      t.jsonb :payload
      t.jsonb :input
      t.jsonb :output
      t.jsonb :error
      t.integer :status, default: 0
      t.datetime :sleep_until
      t.string :type

      t.timestamps
    end

    add_index :durable_flow_step_executions, :type
  end
end
