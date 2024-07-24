class Transaction < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :document, optional: true
  belongs_to :bank_account, optional: true
  belongs_to :bank_account_statement, optional: true
end
