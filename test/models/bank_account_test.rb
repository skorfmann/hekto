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
require "test_helper"

class BankAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
