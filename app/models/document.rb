class Document < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  has_one_attached :file

  before_create :generate_uuid_v7

  private

  def generate_uuid_v7
    self.id = SecureRandom.uuid_v7
  end
end
