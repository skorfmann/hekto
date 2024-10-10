# == Schema Information
#
# Table name: connected_accounts
#
#  id                  :bigint           not null, primary key
#  owner_id            :bigint
#  provider            :string
#  uid                 :string
#  refresh_token       :string
#  expires_at          :datetime
#  auth                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  access_token        :string
#  access_token_secret :string
#  owner_type          :string
#
class ConnectedAccount < ApplicationRecord
  include Token
  include Oauth

  belongs_to :owner, polymorphic: true
end
