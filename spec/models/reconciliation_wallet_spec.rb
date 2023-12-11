# frozen_string_literal: true

RSpec.describe ReconciliationWallet do
  let(:reconciliation_wallet) { build(:reconciliation_wallet) }

  describe 'Basic factory' do
    subject { reconciliation_wallet }

    it { is_expected.to be_valid }
  end

  describe '.currency' do
    subject(:currency) { reconciliation_wallet.currency }

    let(:profile) { create(:profile, currency: :yen) }
    let(:reconciliation_wallet) { build(:reconciliation_wallet, reconciliation:) }

    context 'when reconciliation association is blank' do
      let(:reconciliation) { nil }

      it 'defaults to the system default currency' do
        expect(currency).to eq(Money.default_currency)
      end
    end

    context 'when profile association is present' do
      let(:reconciliation) { build(:reconciliation, profile:) }

      it 'returns the reconciliation currency' do
        expect(currency).to eq(Money::Currency.find(:yen))
      end
    end
  end
end
