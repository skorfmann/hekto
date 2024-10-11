# == Schema Information
#
# Table name: inferences
#
#  id                          :bigint           not null, primary key
#  account_id                  :bigint
#  user_id                     :bigint
#  prompt                      :text
#  response                    :text
#  input_tokens                :integer
#  output_tokens               :integer
#  model                       :string
#  provider                    :string
#  cost_per_1000_input_tokens  :decimal(20, 16)
#  cost_per_1000_output_tokens :decimal(20, 16)
#  subject_type                :string
#  subject_id                  :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
require "test_helper"

class InferenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
