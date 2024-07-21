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
