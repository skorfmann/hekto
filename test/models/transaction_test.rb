# == Schema Information
#
# Table name: transactions
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )
#  description               :string
#  date                      :date
#  external_id               :string
#  account_id                :bigint           not null
#  document_id               :bigint
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  bank_account_id           :bigint           not null
#  bank_account_statement_id :bigint
#  counterparty_name         :string
#  currency                  :string
#
require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
