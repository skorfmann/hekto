require "administrate/base_dashboard"

class DocumentDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    content: Field::Text,
    metadata: JsonbField,
    account: Field::BelongsTo,
    owner: Field::BelongsTo.with_options(class_name: 'User'),
    vendor: Field::BelongsTo,
    file: Field::ActiveStorage,
    transaction_reconciliations: Field::HasMany,
    bank_transactions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :account,
    :owner,
    :vendor
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :content,
    :metadata,
    :account,
    :owner,
    :vendor,
    :file,
    :transaction_reconciliations,
    :bank_transactions,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :content,
    :metadata,
    :account,
    :owner,
    :vendor,
    :file
  ].freeze

  def display_resource(document)
    document.name
  end
end

