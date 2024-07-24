class BankAccount < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account

  has_many :transactions
  has_many :bank_account_statements
end
