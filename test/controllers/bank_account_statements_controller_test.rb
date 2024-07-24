require "test_helper"

class BankAccountStatementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank_account_statement = bank_account_statements(:one)
  end

  test "should get index" do
    get bank_account_statements_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_account_statement_url
    assert_response :success
  end

  test "should create bank_account_statement" do
    assert_difference("BankAccountStatement.count") do
      post bank_account_statements_url, params: {bank_account_statement: {{ bank_account_id: @bank_account_statement.bank_account_id, processed: @bank_account_statement.processed, statement_date: @bank_account_statement.statement_date }}}
    end

    assert_redirected_to bank_account_statement_url(BankAccountStatement.last)
  end

  test "should show bank_account_statement" do
    get bank_account_statement_url(@bank_account_statement)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_account_statement_url(@bank_account_statement)
    assert_response :success
  end

  test "should update bank_account_statement" do
    patch bank_account_statement_url(@bank_account_statement), params: {bank_account_statement: {{ bank_account_id: @bank_account_statement.bank_account_id, processed: @bank_account_statement.processed, statement_date: @bank_account_statement.statement_date }}}
    assert_redirected_to bank_account_statement_url(@bank_account_statement)
  end

  test "should destroy bank_account_statement" do
    assert_difference("BankAccountStatement.count", -1) do
      delete bank_account_statement_url(@bank_account_statement)
    end

    assert_redirected_to bank_account_statements_url
  end
end
