# frozen_string_literal: true

RSpec.describe ProfileShareInvite do
  subject { profile_share_invite }

  let(:profile_share_invite) { build(:profile_share_invite) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end

  describe '.accept!' do
    subject(:accept) { profile_share_invite.accept! }

    let(:profile_share_invite) { create(:profile_share_invite, :pending, invitee_email: 'test@email.com') }

    before { create(:user, email: 'test@email.com') }

    it 'changes the status to accepted and creates a new ProfileShare' do
      expect { accept }
        .to change { ProfileShare.count }
        .by(1)
        .and change { profile_share_invite.reload.status }
        .to('accepted')
    end
  end
end
