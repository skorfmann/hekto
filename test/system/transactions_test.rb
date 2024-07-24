require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    @transaction = transactions(:one)
  end

  test "visiting the index" do
    visit transactions_url
    assert_selector "h1", text: "Transactions"
  end

  test "creating a Transaction" do
    visit transactions_url
    click_on "New Transaction"

    fill_in "Account", with: @transaction.account_id
    fill_in "Amount", with: @transaction.amount
    fill_in "Date", with: @transaction.date
    fill_in "Description", with: @transaction.description
    fill_in "Document", with: @transaction.document_id
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
    assert_selector "h1", text: "Transactions"
  end

  test "updating a Transaction" do
    visit transaction_url(@transaction)
    click_on "Edit", match: :first

    fill_in "Account", with: @transaction.account_id
    fill_in "Amount", with: @transaction.amount
    fill_in "Date", with: @transaction.date
    fill_in "Description", with: @transaction.description
    fill_in "Document", with: @transaction.document_id
    click_on "Update Transaction"

    assert_text "Transaction was successfully updated"
    assert_selector "h1", text: "Transactions"
  end

  test "destroying a Transaction" do
    visit edit_transaction_url(@transaction)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Transaction was successfully destroyed"
  end
end
