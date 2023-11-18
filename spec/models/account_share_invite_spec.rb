# frozen_string_literal: true

RSpec.describe AccountShareInvite do
  subject { account_share_invite }

  let(:account_share_invite) { build(:account_share_invite) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
