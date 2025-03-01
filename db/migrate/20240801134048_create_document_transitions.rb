class CreateDocumentTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :document_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :document_id, null: false
      t.boolean :most_recent, null: false

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :document_transitions, :documents

    add_index(:document_transitions,
              %i[document_id sort_key],
              unique: true,
              name: 'index_document_transitions_parent_sort')
    add_index(:document_transitions,
              %i[document_id most_recent],
              unique: true,
              where: 'most_recent',
              name: 'index_document_transitions_parent_most_recent')
  end
end
