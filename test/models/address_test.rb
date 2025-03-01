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
require "test_helper"

class AddressTest < ActiveSupport::TestCase
  setup do
    @address = Address.new(
      addressable: accounts(:one),
      address_type: "billing",
      line1: "1 Apple Way",
      city: "Cupertino",
      postal_code: 95014,
      country: "US"
    )
  end

  test "updates pay customer if billing address" do
    assert @address.billing?
    assert_raises StandardError do
      @address.stub :update_pay_customer_addresses, -> { raise StandardError } do
        @address.save!
      end
    end
  end

  test "does not update pay customer if shipping address" do
    @address.address_type = :shipping
    assert_nothing_raised do
      @address.stub :update_pay_customer_addresses, -> { raise StandardError } do
        @address.save!
      end
    end
  end

  test "does not update pay customer if addressable is not a pay object" do
    @address.addressable = users(:one)
    assert_nothing_raised do
      @address.stub :update_pay_customer_addresses, -> { raise StandardError } do
        @address.save!
      end
    end
  end
end
