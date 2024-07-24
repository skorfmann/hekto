require 'smarter_csv'

class BankStatementProcessingJob < ApplicationJob
  queue_as :default

  def perform(bank_statement_id)
    Rails.logger.info "Starting BankStatementProcessingJob for bank_statement_id: #{bank_statement_id}"

    bank_account_statement = BankAccountStatement.find(bank_statement_id)
    csv_content = bank_account_statement.file.download
    csv_io = StringIO.new(csv_content)
    csv_io.set_encoding('UTF-8')

    options = {
      strings_as_keys: true,
      strip_chars_from_headers: /[-"]/,
      remove_empty_values: false,
      remove_zero_values: false,
      convert_values_to_numeric: false,
      file_encoding: 'UTF-8'
    }

    csv_data = SmarterCSV.process(csv_io, options)

    Rails.logger.info "CSV parsed with #{csv_data.size} rows"

    identified_columns = identify_columns(csv_data.first.keys)
    puts "Identified columns: #{identified_columns}"
    Rails.logger.info "Identified columns: #{identified_columns}"

    process_transactions(csv_data, identified_columns, bank_account_statement)

    Rails.logger.info "BankStatementProcessingJob completed for bank_statement_id: #{bank_statement_id}"
  rescue StandardError => e
    Rails.logger.error "Error processing bank statement #{bank_statement_id}: #{e.message}"
    # Add additional error handling or notification here
  end

  private

  def identify_columns(headers)
    Rails.logger.info "Identifying columns for headers: #{headers}"
    Anthropic.configure do |config|
      config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
    end

    content = [
      {
        type: 'text',
        text: <<~PROMPT
          Identify the following columns from this CSV header: external id, counterparty name, reference, amount, date, currency.
          Return the result as a JSON object where the keys are the column types and the values are the matching header names.

          CSV Headers: #{headers.join(', ')}

          Example of the expected JSON format:
          {
            "external_id": "Transaction ID",
            "counterparty_name": "Payee",
            "reference": "Transaction Reference",
            "amount": "Amount (EUR)",
            "date": "Transaction Date",
            "currency": "Currency"
          }

          Please provide the JSON object for the given CSV headers, matching as closely as possible to the required column types.
        PROMPT
      }
    ]

    response = Anthropic::Client.new.messages(
      parameters: {
        model: Rails.application.credentials.dig(:anthropic, :model) || 'claude-3-5-sonnet-20240620',
        messages: [
          { role: 'user', content: },
          { role: 'assistant', content: '{' }
        ],
        max_tokens: 1000
      }
    )

    result = response['content'][0]['text']
    Rails.logger.info "Column identification result: #{result}"
    JSON.parse("{#{result}")
  end

  def process_transactions(csv, identified_columns, bank_account_statement)
    Rails.logger.info "Processing #{csv.size} transactions for bank_statement_id: #{bank_account_statement.id}"

    csv.each_with_index do |row, index|
      puts row
      Transaction.create!(
        account: bank_account_statement.account,
        bank_account: bank_account_statement.bank_account,
        bank_account_statement:,
        external_id: row[identified_columns['external_id']],
        counterparty_name: row[identified_columns['counterparty_name']],
        description: row[identified_columns['reference']],
        amount: BigDecimal(row[identified_columns['amount']].to_s.tr(',', '.')),
        date: Date.parse(row[identified_columns['date']]),
        currency: row[identified_columns['currency']]
      )
      Rails.logger.debug "Processed transaction #{index + 1}" if (index + 1) % 100 == 0
    rescue StandardError => e
      Rails.logger.error "Error processing transaction #{index + 1}: #{e.message}"
    end

    Rails.logger.info "Finished processing transactions for bank_statement_id: #{bank_account_statement.id}"
  end
end
