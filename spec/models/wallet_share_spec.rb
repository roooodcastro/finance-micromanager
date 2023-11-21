# frozen_string_literal: true

RSpec.describe WalletShare do
  subject { wallet_share }

  let(:wallet_share) { build(:wallet_share) }

  describe '#validate_no_owner_self_sharing' do
    subject(:errors) do
      wallet_share.valid?
      wallet_share.errors
    end

    let(:wallet_share) { build(:wallet_share, user:, wallet:) }

    context 'when the user is different from the wallet user' do
      let(:user) { create(:user) }
      let(:wallet) { create(:wallet) }

      it { is_expected.to be_empty }
    end

    context 'when both user and wallet user are the same' do
      let(:user) { create(:user) }
      let(:wallet) { create(:wallet, user:) }

      it 'adds an error to the user attribute' do
        expect(errors.size).to eq(1)
        expect(errors.first.type).to eq :owner_self_share
      end
    end
  end
end
