require "administrate/base_dashboard"

class PlanDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    description: Field::String,
    amount: Field::Number,
    stripe_tax: Field::Boolean,
    unit_label: Field::String,
    contact_url: Field::String,
    charge_per_unit: Field::Boolean,
    currency: Field::Select.with_options(collection: Pay::Currency.all.map { |iso, v| ["#{iso.upcase} - #{v["name"]}", iso] }),
    interval: Field::Select.with_options(collection: ["month", "year"]),
    interval_count: Field::Number,
    trial_period_days: Field::Number,
    details: Field::String.with_options(searchable: false),
    stripe_id: Field::String,
    lemon_squeezy_id: Field::String,
    braintree_id: Field::String,
    paddle_billing_id: Field::String,
    paddle_classic_id: Field::String,
    fake_processor_id: Field::String,
    features: ArrayField,
    hidden: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :hidden,
    :amount,
    :currency,
    :interval,
    :interval_count,
    :trial_period_days
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :description,
    :hidden,
    :amount,
    :currency,
    :unit_label,
    :contact_url,
    :interval,
    :interval_count,
    :charge_per_unit,
    :trial_period_days,
    :stripe_tax,
    :stripe_id,
    :lemon_squeezy_id,
    :braintree_id,
    :paddle_billing_id,
    :paddle_classic_id,
    :fake_processor_id,
    :features,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :description,
    :hidden,
    :amount,
    :unit_label,
    :contact_url,
    :currency,
    :interval,
    :interval_count,
    :charge_per_unit,
    :trial_period_days,
    :stripe_tax,
    :stripe_id,
    :lemon_squeezy_id,
    :braintree_id,
    :paddle_billing_id,
    :paddle_classic_id,
    :fake_processor_id,
    :features
  ].freeze

  # Overwrite this method to customize how plans are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(plan)
  #   "Plan ##{plan.id}"
  # end
end
