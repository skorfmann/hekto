require "administrate/base_dashboard"

class TransactionReconciliationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    bank_transaction: Field::BelongsTo.with_options(class_name: 'Transaction'),
    document: Field::BelongsTo,
    reconciliation_date: Field::Date,
    status: Field::String,
    confidence: Field::Number.with_options(decimals: 2),
    reason: Field::Text,
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :bank_transaction,
    :document,
    :status,
    :confidence
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :bank_transaction,
    :document,
    :reconciliation_date,
    :status,
    :confidence,
    :reason,
    :notes,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :bank_transaction,
    :document,
    :reconciliation_date,
    :status,
    :confidence,
    :reason,
    :notes
  ].freeze

  def display_resource(transaction_reconciliation)
    "Transaction Reconciliation ##{transaction_reconciliation.id}"
  end
end
