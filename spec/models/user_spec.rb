# frozen_string_literal: true

RSpec.describe User do
  subject { user }

  let(:user) { build(:user) }

  describe 'default_wallet_validation' do
    context 'for a new User' do
      let(:user) { build(:user) }

      context 'when the user does not have a default wallet' do
        before { user.default_wallet = nil }

        it { is_expected.to be_valid }
      end

      context 'when the user has a default wallet' do
        it { is_expected.to be_valid }
      end
    end

    context 'for an existing User' do
      let(:user) { create(:user) }

      context 'when the user does not have a default wallet' do
        before { user.default_wallet = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when the user has a default wallet' do
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#set_default_wallet' do
    subject(:user_save) { user.save }

    context 'when default wallet exists' do
      let!(:wallet) { create(:wallet, user:) }

      before { user.default_wallet = wallet }

      it 'does not create or set anything' do
        expect { user_save }.to not_change { Wallet.count }.and not_change { user.default_wallet }
      end
    end

    context 'when default wallet is nil' do
      let(:user) { build(:user, default_wallet: nil) }

      it 'creates the default wallet' do
        expect { user_save }.to change { Wallet.count }.by(1)

        new_wallet = Wallet.last

        expect(new_wallet.user).to eq user
        expect(new_wallet.status).to eq 'active'
        expect(new_wallet.currency).to eq 'eur'
        expect(user.reload.default_wallet).to eq new_wallet
      end
    end
  end

  describe '.find_available_wallet' do
    subject(:find_available_wallet) { user.find_available_wallet(id) }

    let(:user) { create(:user) }

    context 'when the wallet cannot be found' do
      let(:id) { 'unknown' }

      it 'raises a RecordNotFound exception' do
        expect { find_available_wallet }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the wallet is found in the user own wallets' do
      let!(:wallet) { create(:wallet, user:) }
      let(:id) { wallet.id }

      it { is_expected.to eq wallet }
    end

    context 'when the wallet is found in the user shared wallets' do
      let!(:wallet) do
        new_wallet = create(:wallet)
        create(:wallet_share, wallet: new_wallet, user: user)
        new_wallet
      end

      let(:id) { wallet.id }

      it { is_expected.to eq wallet }
    end
  end
end
