require 'test_helper'

class Document::ReceiptTest < ActiveSupport::TestCase
  def setup
    @valid_metadata = {
      date: '2023-05-10',
      merchant: {
        name: 'ACME Corp',
        address: '123 Main St'
      },
      items: [
        {
          name: 'Widget',
          quantity: 2,
          price: { amount: 10.99, currency: 'USD' },
          taxRate: 0.20,
          taxAmount: { amount: 4.40, currency: 'USD' }
        }
      ],
      total: {
        net: { amount: 21.98, currency: 'USD' },
        tax: [{ rate: 0.20, amount: { amount: 4.40, currency: 'USD' } }],
        gross: { amount: 26.38, currency: 'USD' }
      },
      payment: {
        method: 'credit_card',
        amount: { amount: 26.38, currency: 'USD' }
      }
    }
    @receipt = document_receipts(:one)
    @receipt.metadata = @valid_metadata
  end

  test "parse method parses the metadata correctly" do
    parsed = @receipt.parsed

    assert_equal Date.new(2023, 5, 10), parsed.date
    assert_equal 'ACME Corp', parsed.merchant.name
    assert_equal '123 Main St', parsed.merchant.address
    assert_equal 'Widget', parsed.items.first.name
    assert_equal 2, parsed.items.first.quantity
    assert_equal BigDecimal('10.99'), parsed.items.first.price.amount
    assert_equal 'USD', parsed.items.first.price.currency
    assert_equal BigDecimal('0.2'), parsed.items.first.taxRate
    assert_equal BigDecimal('21.98'), parsed.total.net.amount
    assert_equal 'USD', parsed.total.net.currency
    assert_equal BigDecimal('0.2'), parsed.total.tax.first.rate
    assert_equal BigDecimal('4.4'), parsed.total.tax.first.amount.amount
    assert_equal BigDecimal('26.38'), parsed.total.gross.amount
    assert_equal 'credit_card', parsed.payment.method
    assert_equal BigDecimal('26.38'), parsed.payment.amount.amount
  end

  test "parse method caches the parsed result" do
    parsed1 = @receipt.parsed
    parsed2 = @receipt.parsed
    assert_equal parsed1.object_id, parsed2.object_id
  end

  test "receipt is valid with valid metadata" do
    WebMock.disable!
    assert @receipt.valid?
    WebMock.enable!
  end

  test "receipt is invalid with invalid metadata" do
    invalid_metadata = @valid_metadata.deep_dup
    invalid_metadata[:date] = 'not a date'
    @receipt.metadata = invalid_metadata
    assert_not @receipt.valid?

    # Check for the specific error message
    expected_error = "Metadata Invalid format for date. Expected ISO 8601 date format (YYYY-MM-DD)"
    assert_includes @receipt.errors.full_messages, expected_error
  end

  test "receipt is invalid with missing required fields" do
    invalid_metadata = @valid_metadata.deep_dup
    invalid_metadata.delete(:date)
    @receipt.metadata = invalid_metadata
    assert_not @receipt.valid?

    # Adjust the assertion based on how errors are actually stored
    assert_includes @receipt.errors.full_messages.join, "date"
  end
end
