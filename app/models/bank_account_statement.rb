class BankAccountStatement < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :bank_account
  has_many :transactions
  has_one_attached :file
end
