class CreateDurableFlowEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :durable_flow_events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :name
      t.jsonb :payload

      t.timestamps
    end
  end
end
