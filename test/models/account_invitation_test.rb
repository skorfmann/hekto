# == Schema Information
#
# Table name: account_invitations
#
#  id            :bigint           not null, primary key
#  account_id    :bigint           not null
#  invited_by_id :bigint
#  token         :string           not null
#  name          :string           not null
#  email         :string           not null
#  roles         :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class AccountInvitationTest < ActiveSupport::TestCase
  setup do
    @account_invitation = account_invitations(:one)
    @account = @account_invitation.account
  end

  test "cannot invite same email twice" do
    invitation = @account.account_invitations.create(name: "whatever", email: @account_invitation.email)
    assert_not invitation.valid?
  end

  test "accept" do
    user = users(:invited)
    assert_difference "AccountUser.count" do
      account_user = @account_invitation.accept!(user)
      assert account_user.persisted?
      assert_equal user, account_user.user
    end

    assert_raises ActiveRecord::RecordNotFound do
      @account_invitation.reload
    end
  end

  test "reject" do
    assert_difference "AccountInvitation.count", -1 do
      @account_invitation.reject!
    end
  end

  test "accept sends notifications account owner and inviter" do
    assert_difference "Noticed::Notification.count", 2 do
      account_invitations(:two).accept!(users(:invited))
    end
    event = Noticed::Event.last
    assert_equal @account, event.account
    assert_equal users(:invited), event.user
  end
end
