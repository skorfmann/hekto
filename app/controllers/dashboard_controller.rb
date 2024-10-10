class DashboardController < ApplicationController
  def show
    @account_name = current_account.name
    @document_count = current_account.documents.count
    @vendor_count = current_account.vendors.count
    @transaction_count = current_account.transactions.count
    @recent_documents = current_account.documents.order(created_at: :desc).limit(5)
  end
end
