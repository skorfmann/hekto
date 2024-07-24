class AddColumnToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :counterparty_name, :string
    add_column :transactions, :currency, :string
  end
end
