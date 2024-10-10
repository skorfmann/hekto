# == Schema Information
#
# Table name: api_tokens
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  token        :string
#  name         :string
#  metadata     :jsonb
#  transient    :boolean          default(FALSE)
#  last_used_at :datetime
#  expires_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
