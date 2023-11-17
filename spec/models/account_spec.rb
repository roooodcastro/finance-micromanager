# frozen_string_literal: true

RSpec.describe Account do
  subject { account }

  let(:account) { build(:account, currency: :eur) }

  describe '.as_json' do
    subject { account.as_json.deep_symbolize_keys }

    let(:account) { create(:account, currency: :eur, name: 'acc') }
    let(:user) { account.user }

    let(:expected_user_json) do
      {
        default_account_id: user.default_account_id,
        display_name:       user.display_name,
        email:              user.email,
        first_name:         user.first_name,
        full_name:          user.full_name,
        id:                 user.id,
        last_name:          user.last_name
      }
    end

    let(:expected_account_json) do
      {
        id:              account.id,
        name:            'acc',
        display_name:    'acc',
        currency:        'eur',
        status:          'active',
        shared:          false,
        user_id:         account.user_id,
        user:            expected_user_json,
        currency_object: { name: 'Euro', symbol: '€' }
      }
    end

    before { Current.user = user }

    it { is_expected.to eq(expected_account_json) }
  end

  describe '.currency_object' do
    subject { account.currency_object }

    it { is_expected.to eq Money::Currency.find(:eur) }
  end

  describe '.display_name' do
    subject { account.display_name }

    context 'when name is nil' do
      let(:account) { build(:account, currency: :eur, name: nil) }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is an empty string' do
      let(:account) { build(:account, currency: :eur, name: '') }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is present' do
      let(:account) { build(:account, currency: :eur, name: 'My name') }

      it { is_expected.to eq 'My name' }
    end
  end

  describe '.shared?' do
    subject { account.shared? }

    context 'when account owner is the logged in user' do
      before { Current.user = account.user }

      it { is_expected.to be(false) }
    end

    context 'when account owner is someone else' do
      before { Current.user = create(:user) }

      it { is_expected.to be(true) }
    end
  end
end
