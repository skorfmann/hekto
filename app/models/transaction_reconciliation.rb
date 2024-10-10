# == Schema Information
#
# Table name: transaction_reconciliations
#
#  id                  :bigint           not null, primary key
#  transaction_id      :bigint           not null
#  document_id         :bigint           not null
#  reconciliation_date :date
#  status              :string
#  confidence          :float            default(0.0), not null
#  reason              :text
#  notes               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class TransactionReconciliation < ApplicationRecord
  belongs_to :bank_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :document

  validates :confidence, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
