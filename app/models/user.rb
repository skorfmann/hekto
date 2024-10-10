# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  first_name             :string
#  last_name              :string
#  time_zone              :string
#  accepted_terms_at      :datetime
#  accepted_privacy_at    :datetime
#  announcements_read_at  :datetime
#  admin                  :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :bigint
#  invitations_count      :integer          default(0)
#  preferred_language     :string
#  otp_required_for_login :boolean
#  otp_secret             :string
#  last_otp_timestep      :integer
#  otp_backup_codes       :text
#  preferences            :jsonb
#  name                   :string
#
class User < ApplicationRecord
  has_prefix_id :user

  include Accounts
  include Agreements
  include Authenticatable
  include Mentions
  include Notifiable
  include Searchable
  include Theme

  has_one_attached :avatar
  has_person_name
  has_many :documents, foreign_key: :user_id

  validates :avatar, resizable_image: true
  validates :name, presence: true
end
