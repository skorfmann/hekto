# == Schema Information
#
# Table name: bank_accounts
#
#  id           :bigint           not null, primary key
#  name         :string
#  number       :string
#  balance      :decimal(, )
#  account_type :string
#  account_id   :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class BankAccount < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account

  has_many :transactions, dependent: :destroy
  has_many :bank_account_statements, dependent: :destroy
end
