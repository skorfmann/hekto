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
class NotificationToken < ApplicationRecord
  # Tokens for sending push notifications to mobile devices

  belongs_to :user
  validates :token, presence: true
  validates :platform, presence: true, inclusion: {in: %w[iOS fcm]}

  scope :android, -> { where(platform: "fcm") }
  scope :ios, -> { where(platform: "iOS") }
end
