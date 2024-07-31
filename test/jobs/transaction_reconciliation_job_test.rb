require 'test_helper'
require 'mocha/minitest' # Add this line to include Mocha

class TransactionReconciliationJobTest < ActiveSupport::TestCase
  test "performs reconciliation when there's a matching document" do
    # Setup
    account = accounts(:one)
    user = users(:one) # Assuming you have a user fixture
    bank_account = bank_accounts(:one) # Use the bank account fixture
    transaction = account.transactions.create!(date: Date.today, amount: 100, currency: 'USD',
                                               description: 'Test transaction',
                                               bank_account:)
    document = account.documents.create!(
      metadata: {
        'date' => Date.today.to_s,
        'total' => { 'gross' => { 'amount' => '100', 'currency' => 'USD' } },
        'merchant' => { 'name' => 'Test Merchant' }
      },
      owner: user # Associate the document with a user
    )

    # Mock Anthropic API call
    mock_anthropic_response = {
      'content' => [{ 'text' => "Document ID: 1\nExplanation: Perfect match in date and amount." }]
    }
    Anthropic::Client.any_instance.expects(:messages).returns(mock_anthropic_response)

    # Perform the job
    TransactionReconciliationJob.perform_now(transaction.id)

    # Assert
    assert_equal document, transaction.transaction_reconciliation.document
  end
end
