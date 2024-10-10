# == Schema Information
#
# Table name: transaction_reconciliations
#
#  id                  :bigint           not null, primary key
#  transaction_id      :bigint           not null
#  document_id         :bigint           not null
#  reconciliation_date :date
#  status              :string
#  confidence          :float            default(0.0), not null
#  reason              :text
#  notes               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require "test_helper"

class TransactionReconciliationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
