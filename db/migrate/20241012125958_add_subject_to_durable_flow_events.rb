class AddSubjectToDurableFlowEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :durable_flow_events, :subject, polymorphic: true, null: true
  end
end
