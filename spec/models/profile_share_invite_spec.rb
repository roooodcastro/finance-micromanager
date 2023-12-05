# frozen_string_literal: true

RSpec.describe ProfileShareInvite do
  subject { profile_share_invite }

  let(:profile_share_invite) { build(:profile_share_invite) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
