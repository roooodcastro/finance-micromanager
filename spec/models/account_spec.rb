# frozen_string_literal: true

RSpec.describe Account do
  subject { account }

  let(:account) { build(:account, currency: :eur) }

  describe '.as_json' do
    subject { account.as_json.deep_symbolize_keys }

    let(:account) { create(:account, currency: :eur, name: 'acc') }

    let(:expected_as_json) do
      {
        id:              account.id,
        name:            'acc',
        display_name:    'acc',
        currency:        'eur',
        status:          'active',
        user_id:         account.user_id,
        currency_object: { name: 'Euro', symbol: '€' }
      }
    end

    it { is_expected.to eq(expected_as_json) }
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
end
