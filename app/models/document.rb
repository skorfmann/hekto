class Document < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  has_one_attached :file

  scope :grouped_by_month, lambda {
    select("*,
            (metadata->>'date')::date AS document_date")
      .order('document_date DESC NULLS LAST')
      .group_by { |doc| doc.document_date&.beginning_of_month }
  }

  after_update :run_document_summary_job, if: :metadata_changed?

  private

  def run_document_summary_job
    DocumentSummaryJob.perform_later(id)
  end

  def metadata_changed?
    saved_change_to_metadata?
  end
end
