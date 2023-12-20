# frozen_string_literal: true

RSpec.describe ReconciliationWallet do
  let(:reconciliation_wallet) { build(:reconciliation_wallet) }

  describe 'Basic factory' do
    subject { reconciliation_wallet }

    it { is_expected.to be_valid }
  end

  describe 'validate_balance_amount_change' do
    subject(:reconciliation_wallet) do
      build(:reconciliation_wallet, reconciliation: reconciliation, balance_amount: 10)
    end

    before { reconciliation_wallet.save }

    context 'when reconciliation is nil' do
      let(:reconciliation) { nil }

      it 'does not add error to balance_amount' do
        expect(reconciliation_wallet.errors[:balance_amount_cents]).to be_empty
      end
    end

    context 'when reconciliation is in progress' do
      let(:reconciliation) { create(:reconciliation, :in_progress) }

      it 'does not add error to balance_amount' do
        expect(reconciliation_wallet.errors[:balance_amount_cents]).to be_empty
      end
    end

    context 'when reconciliation is cancelled' do
      let(:reconciliation) { create(:reconciliation, :cancelled) }

      it 'adds an error to balance_amount' do
        expect(reconciliation_wallet.errors[:balance_amount_cents]).to be_present
        expect(reconciliation_wallet.errors.full_messages)
          .to eq(['Balance cannot be changed after reconciliation is finished or cancelled'])
      end
    end

    context 'when reconciliation is finished' do
      let(:reconciliation) { create(:reconciliation, :finished) }

      it 'adds an error to balance_amount' do
        expect(reconciliation_wallet.errors[:balance_amount_cents]).to be_present
        expect(reconciliation_wallet.errors.full_messages)
          .to eq(['Balance cannot be changed after reconciliation is finished or cancelled'])
      end
    end
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
