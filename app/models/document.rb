# == Schema Information
#
# Table name: documents
#
#  id         :bigint           not null, primary key
#  name       :string
#  content    :text
#  metadata   :jsonb
#  account_id :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vendor_id  :bigint
#

class Document < ApplicationRecord
  broadcasts_refreshes

  belongs_to :account
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  belongs_to :vendor, optional: true

  has_one_attached :file

  has_many :transaction_reconciliations
  has_many :bank_transactions, through: :transaction_reconciliations, source: :bank_transaction

  scope :grouped_by_month, lambda {
    select("DATE_TRUNC('month', (metadata->>'date')::date) AS month, *")
      .order('month DESC')
      .group_by { |doc| doc.month }
  }

  scope :paginated_grouped_by_month, lambda { |page, items_per_page|
    select("DATE_TRUNC('month', (metadata->>'date')::date) AS month, *")
      .order('month DESC')
      .page(page)
      .per(items_per_page)
      .group_by { |doc| doc.month }
  }

  scope :with_metadata, -> { where.not(metadata: nil) }

  scope :in_date_range, lambda { |start_date, end_date|
    where("(metadata->>'date')::date BETWEEN ? AND ?", start_date, end_date)
  }

  after_update :document_changed, if: :metadata_changed?

  private

  def document_changed
    event = DurableFlow::Event.new(subject: self, name: :document_changed, account: account, user: owner)
    DurableFlow::EventBus.publish(event)
  end

  def metadata_changed?
    saved_change_to_metadata?
  end
end
