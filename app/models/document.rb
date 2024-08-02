# == Metadata jsonb schema ==
# type Receipt = {
#   merchant: {
#     name: string;
#     address?: string;
#     phone?: string;
#     email?: string;
#     website?: string;
#     vatNumber?: string;
#     taxNumber?: string;
#   };
#   items: Array<{
#     name: string;
#     quantity: number;
#     price: {
#       amount: number;
#       currency: string; // ISO 4217 currency code
#     };
#     taxRate: number; // VAT tax rate as a decimal (e.g., 0.20 for 20%)
#     taxAmount: {
#       amount: number;
#       currency: string;
#     };
#   }>;
#   total: {
#     net: {
#       amount: number;
#       currency: string;
#     };
#     tax: Array<{
#       rate: number;
#       amount: {
#         amount: number;
#         currency: string;
#       };
#     }>;
#     gross: {
#       amount: number;
#       currency: string;
#     };
#   };
#   payment: {
#     method: string;
#     amount: {
#       amount: number;
#       currency: string;
#     };
#   };
#   date: string; // ISO 8601 date format (YYYY-MM-DD)
#   time?: string; // Time in HH:MM:SS format
#   receipt_number?: string;
# };

class Document < ApplicationRecord
  broadcasts_refreshes

  belongs_to :account
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  belongs_to :vendor, optional: true

  has_one_attached :file

  has_many :transitions, class_name: 'DocumentTransition', autosave: false

  has_many :transaction_reconciliations
  has_many :bank_transactions, through: :transaction_reconciliations, source: :bank_transaction

  scope :grouped_by_month, lambda {
    select("*,
            (metadata->>'date')::date AS document_date")
      .order('document_date DESC NULLS LAST')
      .group_by { |doc| doc.document_date&.beginning_of_month }
  }

  scope :with_metadata, -> { where.not(metadata: nil) }

  scope :in_date_range, lambda { |start_date, end_date|
    where("(metadata->>'date')::date BETWEEN ? AND ?", start_date, end_date)
  }

  after_update :run_document_summary_job, if: :metadata_changed?

  # Initialize the state machine
  def workflow
    @workflow ||= DocumentProcessingWorkflow.new(self, transition_class: DocumentTransition,
                                                       association_name: :transitions)
  end

  # Optionally delegate some methods
  delegate :can_transition_to?,
           :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :workflow

  private

  def run_document_summary_job
    DocumentSummaryJob.perform_later(id)
  end

  def metadata_changed?
    saved_change_to_metadata?
  end
end
