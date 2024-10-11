class CreateInferences < ActiveRecord::Migration[8.0]
  def change
    create_table :inferences do |t|
      # Add references for account and user with cascading delete
      t.references :account, foreign_key: { on_delete: :cascade }
      t.references :user, foreign_key: { on_delete: :cascade }

      # Add text columns for prompt and response
      t.text :prompt
      t.text :response

      # Add columns for token usage and model information
      t.integer :input_tokens
      t.integer :output_tokens
      t.string :model
      t.string :provider

      # Add columns for cost calculation per 1000 tokens with high precision
      t.decimal :cost_per_1000_input_tokens, precision: 20, scale: 16
      t.decimal :cost_per_1000_output_tokens, precision: 20, scale: 16

      # Add polymorphic association for the subject
      t.references :subject, polymorphic: true

      t.timestamps
    end
  end
end
