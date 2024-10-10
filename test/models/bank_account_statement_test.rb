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
require "test_helper"

class BankAccountStatementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
