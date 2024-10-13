require "administrate/base_dashboard"

class VendorDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    address: Field::Text,
    city: Field::String,
    country: Field::String,
    metadata: JsonbField,
    sources: JsonbField,
    account: Field::BelongsTo,
    documents: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :city,
    :country,
    :account
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :address,
    :city,
    :country,
    :metadata,
    :sources,
    :account,
    :documents,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :address,
    :city,
    :country,
    :metadata,
    :sources,
    :account
  ].freeze

  def display_resource(vendor)
    vendor.name
  end
end

