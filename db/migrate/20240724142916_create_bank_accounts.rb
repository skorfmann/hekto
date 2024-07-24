class CreateBankAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.string :number
      t.decimal :balance
      t.string :account_type
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    change_table :transactions do |t|
      t.references :bank_account, null: false, foreign_key: true
    end
  end
end
