# == Schema Information
#
# Table name: durable_flow_events
#
#  id         :bigint           not null, primary key
#  account_id :bigint           not null
#  user_id    :bigint
#  name       :string
#  payload    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class DurableFlow::EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
