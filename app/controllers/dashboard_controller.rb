class DashboardController < ApplicationController
  def show
    @document_count = Document.count
    @vendor_count = Vendor.count
    @transaction_count = Transaction.count
    @recent_documents = Document.order(created_at: :desc).limit(5)
  end
end
