require "administrate/base_dashboard"

class BankAccountDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    number: Field::String,
    balance: Field::Number.with_options(decimals: 2),
    account_type: Field::String,
    account: Field::BelongsTo,
    transactions: Field::HasMany,
    bank_account_statements: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :number,
    :balance,
    :account_type,
    :account
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :number,
    :balance,
    :account_type,
    :account,
    :transactions,
    :bank_account_statements,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :number,
    :balance,
    :account_type,
    :account
  ].freeze

  def display_resource(bank_account)
    bank_account.name
  end
end

