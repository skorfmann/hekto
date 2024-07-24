require 'test_helper'
require 'mocha/minitest' # Add this line to include Mocha

class BankStatementProcessingJobTest < ActiveJob::TestCase
  fixtures :accounts, :bank_accounts, :bank_account_statements

  setup do
    @account = accounts(:one)
    @bank_account = bank_accounts(:one)
    @bank_account_statement = bank_account_statements(:one)

    @csv_content = <<~CSV
      Abrechnungsdatum (UTC);Name der Gegenpartei;Gesamtbetrag (inkl. MwSt.);Währung;Referenz
      30-06-2024 14:38:40;EDEKA NIEMERSZEIN;-37,96;EUR;""
      25-06-2024 15:51:24;Qonto;-9,75;EUR;fx_card_plus
      25-06-2024 15:51:22;Qonto;-6,66;EUR;fx_card_plus
      25-06-2024 15:51:17;Qonto;-0,22;EUR;fx_card_plus
      25-06-2024 15:50:22;LUFTHAN2204027414541;-974,88;EUR;""
      25-06-2024 14:54:02;Telekom Deutschland GmbH;-115,81;EUR;Mobilfunk Kundenkonto 0065039669 RG 39029948012661/13.06.2024
    CSV
    @bank_account_statement.file.attach(io: StringIO.new(@csv_content), filename: 'statement.csv')

    # Assert associations are set correctly
    assert_equal @account, @bank_account_statement.account
    assert_equal @bank_account, @bank_account_statement.bank_account
  end

  # The CSV library transforms header names to lowercase, replaces spaces with underscores, and encloses special characters in parentheses
  test 'identifies columns correctly' do
    BankStatementProcessingJob.any_instance.expects(:identify_columns).returns({
                                                                                 'counterparty_name' => 'name_der_gegenpartei',
                                                                                 'reference' => 'referenz',
                                                                                 'amount' => 'gesamtbetrag_(inkl._mwst.)',
                                                                                 'date' => 'abrechnungsdatum_(utc)',
                                                                                 'currency' => 'währung'
                                                                               })

    BankStatementProcessingJob.perform_now(@bank_account_statement.id)

    transaction = Transaction.last
    assert_not_nil transaction, 'No transaction was created'
    if transaction
      assert_equal 'Telekom Deutschland GmbH', transaction.counterparty_name
      assert_equal 'Mobilfunk Kundenkonto 0065039669 RG 39029948012661/13.06.2024', transaction.description
      assert_equal BigDecimal('-115.81'), transaction.amount
      assert_equal Date.parse('2024-06-25'), transaction.date
      assert_equal 'EUR', transaction.currency
    end
  end

  private

  def assert_logged(message)
    assert_equal(true, Rails.logger.error_messages.any? { |log| log.include?(message) })
  end
end
