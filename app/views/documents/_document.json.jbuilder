json.extract! document, :id, :name, :content, :metadata, :account_id, :user_id, :created_at, :updated_at
json.url document_url(document, format: :json)
