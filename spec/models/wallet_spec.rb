# frozen_string_literal: true

RSpec.describe Wallet do
  subject { wallet }

  let(:wallet) { build(:wallet, currency: :eur) }

  describe '.as_json' do
    subject { wallet.as_json.deep_symbolize_keys }

    let(:wallet) { create(:wallet, currency: :eur, name: 'acc') }
    let(:user) { wallet.user }

    let(:expected_user_json) do
      {
        default_wallet_id: user.default_wallet_id,
        display_name:      user.display_name,
        email:             user.email,
        first_name:        user.first_name,
        full_name:         user.full_name,
        id:                user.id,
        last_name:         user.last_name
      }
    end

    let(:expected_wallet_json) do
      {
        id:              wallet.id,
        name:            'acc',
        display_name:    'acc',
        currency:        'eur',
        status:          'active',
        shared:          false,
        user_id:         wallet.user_id,
        user:            expected_user_json,
        currency_object: { name: 'Euro', symbol: '€' }
      }
    end

    before { Current.user = user }

    it { is_expected.to eq(expected_wallet_json) }
  end

  describe '.currency_object' do
    subject { wallet.currency_object }

    it { is_expected.to eq Money::Currency.find(:eur) }
  end

  describe '.display_name' do
    subject { wallet.display_name }

    context 'when name is nil' do
      let(:wallet) { build(:wallet, currency: :eur, name: nil) }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is an empty string' do
      let(:wallet) { build(:wallet, currency: :eur, name: '') }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is present' do
      let(:wallet) { build(:wallet, currency: :eur, name: 'My name') }

      it { is_expected.to eq 'My name' }
    end
  end

  describe '.shared?' do
    subject { wallet.shared? }

    context 'when wallet owner is the logged in user' do
      before { Current.user = wallet.user }

      it { is_expected.to be(false) }
    end

    context 'when wallet owner is someone else' do
      before { Current.user = create(:user) }

      it { is_expected.to be(true) }
    end
  end
end
