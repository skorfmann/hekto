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
class DurableFlow::Event < ApplicationRecord
end
