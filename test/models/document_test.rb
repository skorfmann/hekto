# == Schema Information
#
# Table name: documents
#
#  id         :bigint           not null, primary key
#  name       :string
#  content    :text
#  metadata   :jsonb
#  account_id :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vendor_id  :bigint
#
require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
