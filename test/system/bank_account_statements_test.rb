require "application_system_test_case"

class BankAccountStatementsTest < ApplicationSystemTestCase
  setup do
    @bank_account_statement = bank_account_statements(:one)
  end

  test "visiting the index" do
    visit bank_account_statements_url
    assert_selector "h1", text: "Bank Account Statements"
  end

  test "creating a Bank account statement" do
    visit bank_account_statements_url
    click_on "New Bank Account Statement"

    fill_in "Bank account", with: @bank_account_statement.bank_account_id
    check "Processed" if @bank_account_statement.processed
    fill_in "Statement date", with: @bank_account_statement.statement_date
    click_on "Create Bank account statement"

    assert_text "Bank account statement was successfully created"
    assert_selector "h1", text: "Bank Account Statements"
  end

  test "updating a Bank account statement" do
    visit bank_account_statement_url(@bank_account_statement)
    click_on "Edit", match: :first

    fill_in "Bank account", with: @bank_account_statement.bank_account_id
    check "Processed" if @bank_account_statement.processed
    fill_in "Statement date", with: @bank_account_statement.statement_date
    click_on "Update Bank account statement"

    assert_text "Bank account statement was successfully updated"
    assert_selector "h1", text: "Bank Account Statements"
  end

  test "destroying a Bank account statement" do
    visit edit_bank_account_statement_url(@bank_account_statement)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Bank account statement was successfully destroyed"
  end
end
