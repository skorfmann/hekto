json.extract! transaction, :id, :amount, :description, :date, :account_id, :document_id, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
