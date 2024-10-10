# == Schema Information
#
# Table name: transactions
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )
#  description               :string
#  date                      :date
#  external_id               :string
#  account_id                :bigint           not null
#  document_id               :bigint
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  bank_account_id           :bigint           not null
#  bank_account_statement_id :bigint
#  counterparty_name         :string
#  currency                  :string
#
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
