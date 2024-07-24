require "application_system_test_case"

class VendorsTest < ApplicationSystemTestCase
  setup do
    @vendor = vendors(:one)
  end

  test "visiting the index" do
    visit vendors_url
    assert_selector "h1", text: "Vendors"
  end

  test "creating a Vendor" do
    visit vendors_url
    click_on "New Vendor"

    fill_in "Account", with: @vendor.account_id
    fill_in "Address", with: @vendor.address
    fill_in "City", with: @vendor.city
    fill_in "Country", with: @vendor.country
    fill_in "Metadata", with: @vendor.metadata
    fill_in "Name", with: @vendor.name
    fill_in "Sources", with: @vendor.sources
    click_on "Create Vendor"

    assert_text "Vendor was successfully created"
    assert_selector "h1", text: "Vendors"
  end

  test "updating a Vendor" do
    visit vendor_url(@vendor)
    click_on "Edit", match: :first

    fill_in "Account", with: @vendor.account_id
    fill_in "Address", with: @vendor.address
    fill_in "City", with: @vendor.city
    fill_in "Country", with: @vendor.country
    fill_in "Metadata", with: @vendor.metadata
    fill_in "Name", with: @vendor.name
    fill_in "Sources", with: @vendor.sources
    click_on "Update Vendor"

    assert_text "Vendor was successfully updated"
    assert_selector "h1", text: "Vendors"
  end

  test "destroying a Vendor" do
    visit edit_vendor_url(@vendor)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Vendor was successfully destroyed"
  end
end
