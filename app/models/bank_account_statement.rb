# == Schema Information
#
# Table name: bank_account_statements
#
#  id              :bigint           not null, primary key
#  bank_account_id :bigint           not null
#  account_id      :bigint           not null
#  statement_date  :date
#  processed       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class BankAccountStatement < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :bank_account
  has_many :transactions
  has_one_attached :file
end
