require "administrate/base_dashboard"

class TransactionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    amount: Field::Number.with_options(decimals: 2),
    description: Field::String,
    date: Field::Date,
    external_id: Field::String,
    account: Field::BelongsTo,
    document: Field::BelongsTo,
    bank_account: Field::BelongsTo,
    bank_account_statement: Field::BelongsTo,
    counterparty_name: Field::String,
    currency: Field::String,
    transaction_reconciliation: Field::HasOne,
    reconciled_document: Field::HasOne,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :amount,
    :description,
    :date,
    :account,
    :bank_account
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :amount,
    :description,
    :date,
    :external_id,
    :account,
    :document,
    :bank_account,
    :bank_account_statement,
    :counterparty_name,
    :currency,
    :transaction_reconciliation,
    :reconciled_document,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :amount,
    :description,
    :date,
    :external_id,
    :account,
    :document,
    :bank_account,
    :bank_account_statement,
    :counterparty_name,
    :currency
  ].freeze

  def display_resource(transaction)
    "Transaction ##{transaction.id}"
  end
end
