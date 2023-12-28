# frozen_string_literal: true

RSpec.describe Reconciliations::FinishReconciliation do
  let(:service) { described_class.new(reconciliation) }

  describe '#self.call' do
    it 'creates a new instance and runs "call"' do
      expect_any_instance_of(described_class).to receive(:call) # rubocop:disable RSpec/AnyInstance
      described_class.call(instance_double(Reconciliation, finished!: true))
    end
  end

  describe '.call', :aggregate_errors do
    subject(:service_call) { service.call }

    let(:user) { create(:user) }
    let(:profile) { create(:profile, user: user, balance_amount: 0) }
    let(:reconciliation) { create(:reconciliation, :in_progress, profile:) }

    let(:wallet_a) { create(:wallet, profile: profile, balance: 0) }
    let(:wallet_b) { create(:wallet, profile: profile, balance: 0) }

    let(:category) { create(:category, profile: profile, category_type: :system) }

    before do
      wallet_a
      create(:transaction, profile: profile, wallet: wallet_a, transaction_date: 1.day.ago, amount: 10)
      create(:transaction, profile: profile, wallet: wallet_b, transaction_date: 1.day.from_now, amount: -5)
      create(:reconciliation_wallet, reconciliation: reconciliation, wallet: wallet_a,
             balance_amount: new_wallet_a_balance)
      create(:reconciliation_wallet, reconciliation: reconciliation, wallet: wallet_b,
             balance_amount: new_wallet_b_balance)

      allow(Category).to receive(:reconciliation_category_for).with(profile).and_return(category)
    end

    context 'when balance difference is zero at the end' do
      let(:new_wallet_a_balance) { 15 }
      let(:new_wallet_b_balance) { -5 }

      it 'updates the wallet balance and marks reconciliation as finished, but does not create a transaction' do
        expect { service_call }
          .to not_change { Transaction.count }
          .and change { wallet_a.reload.balance.to_f }
          .to(15)
          .and change { wallet_b.reload.balance.to_f }
          .to(-10)
          .and not_change { profile.reload.balance_amount.to_f }
          .and change { reconciliation.reload.status }
          .to('finished')
          .and not_change { reconciliation.balance_correction_transaction }
          .and not_change { reconciliation.difference_amount.to_f }
          .and change { reconciliation.final_balance_amount.to_f }
          .to(10)
      end
    end

    context 'when there is a balance difference' do
      let(:new_wallet_a_balance) { 15 }
      let(:new_wallet_b_balance) { 5 }

      it 'updates the wallet balance, marks reconciliation as finished, and creates a transaction' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { wallet_a.reload.balance.to_f }
          .to(15)
          .and change { wallet_b.reload.balance.to_f }
          .to(0)
          .and change { profile.reload.balance_amount.to_f }
          .to(15)
          .and change { reconciliation.reload.status }
          .to('finished')
          .and change { reconciliation.balance_correction_transaction }
          .and change { reconciliation.difference_amount.to_f }
          .to(10)
          .and change { reconciliation.final_balance_amount.to_f }
          .to(20)

        transaction = Transaction.last
        expect(reconciliation.reload.balance_correction_transaction).to eq(transaction)
        expect(transaction.name).to eq('reconciliations.transaction_name')
        expect(transaction.amount.to_f).to eq(10.0)
        expect(transaction.transaction_date).to eq(reconciliation.date)
        expect(transaction.category).to eq(category)
        expect(transaction.wallet).to be_nil
      end
    end

    context 'when an error happens' do
      let(:new_wallet_a_balance) { 15 }
      let(:new_wallet_b_balance) { 5 }
      let(:category) { nil }

      it 'does not change anything' do
        expect { service_call }
          .to not_change { Transaction.count }
          .and not_change { wallet_a.reload.balance.to_f }
          .and not_change { wallet_b.reload.balance.to_f }
          .and not_change { profile.reload.balance_amount.to_f }
          .and not_change { reconciliation.reload.status }
      end
    end
  end
end
