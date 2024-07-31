class TransactionReconciliation < ApplicationRecord
  belongs_to :bank_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :document

  validates :confidence, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
