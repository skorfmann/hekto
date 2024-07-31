require 'open_exchange_rates'

class TransactionReconciliationJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    Rails.logger.debug "Starting reconciliation for transaction #{transaction_id}"

    # Step 1: Find documents within a generous date range
    potential_matches = find_documents_by_date_range(transaction)
    Rails.logger.debug "Found #{potential_matches.count} potential matches by date range"

    # Step 2: Rule out obviously non-matching documents
    filtered_matches = filter_potential_matches(transaction, potential_matches)
    Rails.logger.debug "Filtered to #{filtered_matches.count} matches after applying amount and date criteria"

    if filtered_matches.any?
      # Step 3: Send remaining matches to Anthropic for selection
      Rails.logger.debug "Sending #{filtered_matches.count} matches to Anthropic for selection"
      best_match, anthropic_response = select_best_match_with_anthropic(transaction, filtered_matches)

      if best_match
        # Create or update the reconciliation record for the best match
        reconciliation = TransactionReconciliation.find_or_initialize_by(bank_transaction: transaction)
        reconciliation.update!(
          document: best_match,
          reason: anthropic_response
        )
        Rails.logger.info "Found best match for transaction #{transaction_id}: Document #{best_match.id}"
      else
        Rails.logger.info "Anthropic couldn't determine a match for transaction #{transaction_id}"
      end
    else
      Rails.logger.info "No potential matches found for transaction #{transaction_id}"
    end
  end

  private

  def find_documents_by_date_range(transaction)
    date_range = (transaction.date - 7.days)..(transaction.date + 7.days)
    Rails.logger.debug "Searching for documents in date range: #{date_range}"
    documents = Document.with_metadata
                        .where("(metadata->>'date')::date BETWEEN ? AND ?", date_range.begin, date_range.end)
    Rails.logger.debug "Found #{documents.count} documents in date range"
    documents
  end

  def filter_potential_matches(transaction, potential_matches)
    Rails.logger.debug "Filtering #{potential_matches.count} potential matches"
    filtered = potential_matches.select do |document|
      amount_match = amount_within_range?(transaction, document)
      date_match = date_within_range?(transaction.date, document.metadata['date'])
      Rails.logger.debug "Document #{document.id}: Amount match: #{amount_match}, Date match: #{date_match}"
      amount_match && date_match
    end
    Rails.logger.debug "Filtered to #{filtered.count} matches"
    filtered
  end

  def amount_within_range?(transaction, document)
    transaction_money = Money.new(transaction.amount.abs * 100, transaction.currency)
    document_money = Money.new((document.metadata['total']['gross']['amount'].to_d.abs * 100).round,
                               document.metadata['total']['gross']['currency'])

    converted_document_amount = convert_currency(transaction, document)

    # Handle the case where conversion fails
    return false if converted_document_amount.nil?

    difference = (transaction_money - converted_document_amount).abs
    threshold = [transaction_money * 0.3, Money.new(500, transaction.currency)].max

    within_range = difference <= threshold
    Rails.logger.debug "Amount comparison: Transaction: #{transaction_money.format}, Document: #{document_money.format}, Converted: #{converted_document_amount.format}, Difference: #{difference.format}, Threshold: #{threshold.format}, Within range: #{within_range}"
    within_range
  end

  def date_within_range?(transaction_date, document_date)
    (transaction_date - Date.parse(document_date)).abs <= 5 # Allow ±3 days difference
  end

  def convert_currency(transaction, document)
    transaction_money = Money.new(transaction.amount.abs * 100, transaction.currency)
    document_money = Money.new((document.metadata['total']['gross']['amount'].to_d.abs * 100).round,
                               document.metadata['total']['gross']['currency'])

    if transaction_money.currency == document_money.currency
      document_money
    else
      conversion_date = [transaction.date, Date.parse(document.metadata['date'])].min
      fx = OpenExchangeRates::Rates.new

      converted_amount = fx.convert(document_money.cents / 100.0,
                                    from: document_money.currency,
                                    to: transaction_money.currency,
                                    on: conversion_date)

      Money.new((converted_amount * 100).round, transaction_money.currency)
    end
  rescue StandardError => e
    Rails.logger.error "Currency conversion error for #{conversion_date}: #{e.message}"
    nil
  end

  def select_best_match_with_anthropic(transaction, filtered_matches)
    # Configure Anthropic client
    Anthropic.configure do |config|
      config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
    end

    content = [
      {
        type: 'text',
        text: <<~PROMPT
          <task>
          Given a bank transaction and a list of potential matching documents, select the best match or indicate if there's no suitable match.
          </task>

          <bank_transaction>
          - Date: #{transaction.date}
          - Amount: #{transaction.amount} #{transaction.currency}
          - Absolute Amount: #{transaction.amount.abs} #{transaction.currency}
          - Description: #{transaction.description}
          - Counterparty: #{transaction.counterparty_name}
          </bank_transaction>

          <potential_matches>
          #{filtered_matches.map.with_index do |doc, index|
            converted_amount = convert_currency(transaction, doc)
            <<~DOC
              <document id="#{index + 1}">
              - Date: #{doc.metadata['date']}
              - Original Amount: #{doc.metadata['total']['gross']['amount']} #{doc.metadata['total']['gross']['currency']}
              - Converted Amount: #{converted_amount.format}
              - Merchant: #{doc.metadata['merchant']['name']}
              </document>
            DOC
          end.join("\n")}
          </potential_matches>

          <instructions>
          Analyze the bank transaction and potential matching documents. Compare the transaction's amount with the converted document amounts when looking for matches. Then:
          1. If there's a suitable match, respond with the document ID of the best matching document (e.g., "1" for Document 1).
          2. If there's no suitable match, respond with "No match".
          3. Provide a brief explanation for your choice.
          </instructions>

          <response_format>
          Document ID: [Your answer]
          Explanation: [Your explanation]
          </response_format>
        PROMPT
      }
    ]

    Rails.logger.debug "Anthropic API request content: #{content.inspect}"
    response = Anthropic::Client.new.messages(
      parameters: {
        model: Rails.application.credentials.dig(:anthropic, :model) || 'claude-3-5-sonnet-20240620',
        messages: [
          { role: 'user', content: }
        ],
        max_tokens: 1000
      }
    )
    Rails.logger.debug "Anthropic API response: #{response.inspect}"

    result = response['content'][0]['text']
    Rails.logger.debug "Parsed Anthropic response: #{result}"

    # Parse the result to get the best match
    match_id = result.match(/Document ID: (.+)/)&.captures&.first&.strip

    if match_id == 'No match'
      Rails.logger.info "Anthropic response: No suitable match found for transaction #{transaction.id}"
      [nil, result]
    elsif match_id
      match_index = match_id.to_i - 1
      best_match = filtered_matches[match_index]
      Rails.logger.info "Anthropic selected Document #{match_id} as the best match for transaction #{transaction.id}"
      [best_match, result]
    else
      Rails.logger.error "Unexpected response format from Anthropic for transaction #{transaction.id}"
      [nil, result]
    end
  rescue StandardError => e
    Rails.logger.error "Error in Anthropic API call for transaction #{transaction.id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    [nil, "Error: #{e.message}"]
  end
end
