class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.string :description
      t.date :date
      t.string :external_id
      t.references :account, null: false, foreign_key: true
      t.references :document, null: true, foreign_key: true

      t.timestamps
    end
  end
end
