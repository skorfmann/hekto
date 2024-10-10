# == Schema Information
#
# Table name: notification_tokens
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  token      :string           not null
#  platform   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class NotificationTokenTest < ActiveSupport::TestCase
  test "ios" do
    assert_includes NotificationToken.ios, notification_tokens(:ios)
  end

  test "android" do
    assert_includes NotificationToken.android, notification_tokens(:android)
  end
end
