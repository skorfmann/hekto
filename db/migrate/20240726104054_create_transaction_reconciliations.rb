class CreateTransactionReconciliations < ActiveRecord::Migration[7.2]
  def change
    create_table :transaction_reconciliations do |t|
      t.references :transaction, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.date :reconciliation_date
      t.string :status
      t.float :confidence, null: false, default: 0.0
      t.text :reason
      t.text :notes

      t.timestamps
    end
  end
end
