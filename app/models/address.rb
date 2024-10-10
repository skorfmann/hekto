# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  addressable_type :string           not null
#  addressable_id   :bigint           not null
#  address_type     :integer
#  line1            :string
#  line2            :string
#  city             :string
#  state            :string
#  country          :string
#  postal_code      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum :address_type, [:billing, :shipping]
  validates :address_type, :line1, :city, :postal_code, :country, presence: true

  after_commit :update_pay_customer_addresses, if: -> { billing? && addressable.respond_to?(:pay_customers) }

  def to_stripe
    {
      city: city,
      country: country,
      line1: line1,
      line2: line2,
      postal_code: postal_code,
      state: state
    }
  end

  private

  def update_pay_customer_addresses
    addressable.pay_customers.each(&:update_customer!)
  end
end
