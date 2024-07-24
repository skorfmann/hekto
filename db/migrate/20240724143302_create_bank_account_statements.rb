class CreateBankAccountStatements < ActiveRecord::Migration[7.2]
  def change
    create_table :bank_account_statements do |t|
      t.references :bank_account, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.date :statement_date
      t.boolean :processed

      t.timestamps
    end

    change_table :transactions do |t|
      t.references :bank_account_statement, null: true, foreign_key: true
    end
  end
end
