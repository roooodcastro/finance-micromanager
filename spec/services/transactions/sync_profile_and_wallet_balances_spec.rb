# frozen_string_literal: true

RSpec.describe Transactions::SyncProfileAndWalletBalances, type: :service do
  describe '.call' do
    subject(:service_call) { described_class.call(profile:) }

    let(:profile) { create(:profile) }
    let(:wallet_a) { create(:wallet, profile: profile, balance: 0) }
    let(:wallet_b) { create(:wallet, profile: profile, balance: 0) }

    let(:query_result) do
      [
        { 'wallet_id' => nil, 'amount_cents' => 18_000 },
        { 'wallet_id' => wallet_a.id, 'amount_cents' => 2000 },
        { 'wallet_id' => wallet_b.id, 'amount_cents' => 5099 }
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
