json.extract! bank_account_statement, :id, :bank_account_id, :statement_date, :file, :processed, :created_at, :updated_at
json.url bank_account_statement_url(bank_account_statement, format: :json)
json.file url_for(bank_account_statement.file)
