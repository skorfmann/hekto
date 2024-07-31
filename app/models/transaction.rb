class Transaction < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :bank_account, optional: true
  belongs_to :bank_account_statement, optional: true

  has_one :transaction_reconciliation, foreign_key: :transaction_id
  has_one :reconciled_document, through: :transaction_reconciliation, source: :document

  # Add this method to easily check if the transaction is reconciled
  def reconciled?
    transaction_reconciliation.present?
  end
end
