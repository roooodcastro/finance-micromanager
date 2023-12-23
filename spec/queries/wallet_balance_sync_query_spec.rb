# frozen_string_literal: true

RSpec.describe WalletBalanceSyncQuery, type: :query do
  describe 'results' do
    subject(:results) { described_class.run(profile_id:) }

    let(:profile) { create(:profile) }
    let(:profile_id) { profile.id }

    let!(:wallet_a) { create(:wallet, profile:) }
    let!(:wallet_b) { create(:wallet, profile:) }

    context 'when there are no transactions' do
      it { is_expected.to be_empty }
    end

    context 'when there are transactions for different wallets' do
      let(:expected_results) do
        [
          described_class::WalletBalance.new(wallet_a.id, 300, profile.currency),
          described_class::WalletBalance.new(wallet_b.id, -500, profile.currency)
        ]
      end

      before do
        create(:transaction, profile: profile, wallet: wallet_a, amount: 5)
        create(:transaction, profile: profile, wallet: wallet_a, amount: -2)
        create(:transaction, profile: profile, wallet: wallet_b, amount: -3)
        create(:transaction, profile: profile, wallet: wallet_b, amount: -2)
      end

      it 'includes sums of balances from those transactions grouped by wallets in the results' do
        expect(results).to match_array(expected_results)
      end
    end

    context 'when there are transactions with no wallets assigned' do
      let(:expected_results) do
        [
          described_class::WalletBalance.new(wallet_a.id, 300, profile.currency),
          described_class::WalletBalance.new(nil, -500, profile.currency)
        ]
      end

      before do
        create(:transaction, profile: profile, wallet: wallet_a, amount: 5)
        create(:transaction, profile: profile, wallet: wallet_a, amount: -2)
        create(:transaction, profile: profile, wallet: nil, amount: -3)
        create(:transaction, profile: profile, wallet: nil, amount: -2)
      end

      it 'includes sums of balances from those transactions' do
        expect(results).to match_array(expected_results)
      end
    end

    context 'when profile has a finished reconciliation and there are transactions before that' do
      let(:expected_results) { [described_class::WalletBalance.new(wallet_a.id, 800, profile.currency)] }

      before do
        create(:transaction, profile: profile, wallet: wallet_a, transaction_date: 2.days.ago, amount: 5)
        reconciliation = create(:reconciliation, profile: profile, date: 2.days.ago)
        create(:reconciliation_wallet, reconciliation: reconciliation, wallet: wallet_a, balance_amount: 10)
        reconciliation.finished!
        create(:transaction, profile: profile, wallet: wallet_a, transaction_date: 1.day.ago, amount: -2)
      end

      it 'does not include sums of balances from those transactions' do
        expect(results).to match_array(expected_results)
      end
    end

    context 'when profile has multiple finished reconciliations and there are transactions before that' do
      let(:expected_results) { [described_class::WalletBalance.new(wallet_a.id, 800, profile.currency)] }

      before do
        reconciliation = create(:reconciliation, profile: profile, date: 5.days.ago)
        create(:reconciliation_wallet, reconciliation: reconciliation, wallet: wallet_a, balance_amount: 5)
        reconciliation.finished!

        create(:transaction, profile: profile, wallet: wallet_a, transaction_date: 2.days.ago, amount: 5)
        reconciliation = create(:reconciliation, profile: profile, date: 2.days.ago)
        create(:reconciliation_wallet, reconciliation: reconciliation, wallet: wallet_a, balance_amount: 10)
        reconciliation.finished!
        create(:transaction, profile: profile, wallet: wallet_a, transaction_date: 1.day.ago, amount: -2)
      end

      it 'does not include sums of balances from those transactions' do
        expect(results).to match_array(expected_results)
      end
    end
  end
end
