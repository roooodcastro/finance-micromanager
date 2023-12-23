# frozen_string_literal: true

RSpec.describe Transactions::SyncProfileAndWalletBalances, type: :service do
  describe '.call' do
    subject(:service_call) { described_class.call(profile:) }

    let(:profile) { create(:profile) }
    let(:wallet_a) { create(:wallet, profile: profile, balance: 0) }
    let(:wallet_b) { create(:wallet, profile: profile, balance: 0) }

    let(:query_result) do
      [
        WalletBalanceSyncQuery::WalletBalance.new(nil, 18_000, 'eur'),
        WalletBalanceSyncQuery::WalletBalance.new(wallet_a.id, 2000, 'eur'),
        WalletBalanceSyncQuery::WalletBalance.new(wallet_b.id, 5099, 'eur')
      ]
    end

    before do
      allow(WalletBalanceSyncQuery).to receive(:run).with(profile_id: profile.id).and_return(query_result)
    end

    it 'updates all wallets and profile with updated balances from query' do
      expect { service_call }
        .to change { wallet_a.reload.balance.to_f }
        .to(20)
        .and change { wallet_b.reload.balance.to_f }
        .to(50.99)
        .and change { profile.reload.balance_amount.to_f }
        .to(250.99)
    end
  end
end
