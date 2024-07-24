require "application_system_test_case"

class BankAccountsTest < ApplicationSystemTestCase
  setup do
    @bank_account = bank_accounts(:one)
  end

  test "visiting the index" do
    visit bank_accounts_url
    assert_selector "h1", text: "Bank Accounts"
  end

  test "creating a Bank account" do
    visit bank_accounts_url
    click_on "New Bank Account"

    fill_in "Account", with: @bank_account.account_id
    fill_in "Account type", with: @bank_account.account_type
    fill_in "Balance", with: @bank_account.balance
    fill_in "Name", with: @bank_account.name
    fill_in "Number", with: @bank_account.number
    click_on "Create Bank account"

    assert_text "Bank account was successfully created"
    assert_selector "h1", text: "Bank Accounts"
  end

  test "updating a Bank account" do
    visit bank_account_url(@bank_account)
    click_on "Edit", match: :first

    fill_in "Account", with: @bank_account.account_id
    fill_in "Account type", with: @bank_account.account_type
    fill_in "Balance", with: @bank_account.balance
    fill_in "Name", with: @bank_account.name
    fill_in "Number", with: @bank_account.number
    click_on "Update Bank account"

    assert_text "Bank account was successfully updated"
    assert_selector "h1", text: "Bank Accounts"
  end

  test "destroying a Bank account" do
    visit edit_bank_account_url(@bank_account)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Bank account was successfully destroyed"
  end
end
