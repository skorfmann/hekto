class BankAccount < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account

  has_many :transactions, dependent: :destroy
  has_many :bank_account_statements, dependent: :destroy
end
