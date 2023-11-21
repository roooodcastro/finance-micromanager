# frozen_string_literal: true

RSpec.describe WalletShareInvite do
  subject { wallet_share_invite }

  let(:wallet_share_invite) { build(:wallet_share_invite) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
