# frozen_string_literal: true

RSpec.describe Transactions::UpdateAssociatedBalances do
  describe '.call' do
    let(:profile) { create(:profile, balance_amount: 50) }

    context 'when the transaction is being created' do
      subject(:create_transaction) { transaction.save! }

      let(:transaction) { build(:transaction, profile: profile, amount: 3, wallet: wallet) }

      context 'and wallet is nil' do
        let(:wallet) { nil }

        it 'updates the profile balance' do
          expect { create_transaction }.to change { profile.reload.balance_amount.to_f }.by(3)
        end
      end

      context 'and wallet is present' do
        let(:wallet) { create(:wallet, profile:) }

        it 'updates the profile balance and wallet balance' do
          expect { create_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(3)
            .and change { wallet.reload.balance.to_f }
            .by(3)
        end
      end
    end

    context 'when the transaction is being updated' do
      subject(:update_transaction) { transaction.update!(update_params) }

      let!(:transaction) { create(:transaction, profile: profile, amount: 3, wallet: wallet) }

      context 'and amount changes and wallet is nil' do
        let(:update_params) { { amount: 5 } }
        let(:wallet) { nil }

        it 'updates the profile balance with the amount difference' do
          expect { update_transaction }.to change { profile.reload.balance_amount.to_f }.by(2)
        end
      end

      context 'and amount does not change and wallet is present' do
        let(:update_params) { { name: 'Other Name' } }
        let(:wallet) { create(:wallet, profile:) }

        it 'does not update anything' do
          expect { update_transaction }
            .to not_change { profile.reload.balance_amount.to_f }
            .and not_change { wallet.reload.balance.to_f }
        end
      end

      context 'and amount does not change and wallet is nil and is being set to a new wallet' do
        let(:update_params) { { name: 'Other Name', wallet: new_wallet } }
        let(:wallet) { nil }
        let(:new_wallet) { create(:wallet, profile:) }

        it 'updates only the new wallet balance with the amount' do
          expect { update_transaction }
            .to not_change { profile.reload.balance_amount.to_f }
            .and change { new_wallet.reload.balance.to_f }
            .by(3)
        end
      end

      context 'and amount changes and wallet is nil and is being set to a new wallet' do
        let(:update_params) { { amount: 5, wallet: new_wallet } }
        let(:wallet) { nil }
        let(:new_wallet) { create(:wallet, profile:) }

        it 'updates the profile with the difference and the new wallet with the amount' do
          expect { update_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(2)
            .and change { new_wallet.reload.balance.to_f }
            .by(5)
        end
      end

      context 'and amount changes and wallet is present and remains the same' do
        let(:update_params) { { amount: 5 } }
        let(:wallet) { create(:wallet, profile:) }

        it 'updates the profile and wallet balances with the amount difference' do
          expect { update_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(2)
            .and change { wallet.reload.balance.to_f }
            .by(2)
        end
      end

      context 'and amount does not change and wallet is present and is being swapped with another' do
        let(:update_params) { { name: 'Other Name', wallet: other_wallet } }

        let(:wallet) { create(:wallet, profile:) }
        let(:other_wallet) { create(:wallet, profile:) }

        it 'updates both new and old wallets balances with the amount' do
          expect { update_transaction }
            .to not_change { profile.reload.balance_amount.to_f }
            .and change { wallet.reload.balance.to_f }
            .by(-3)
            .and change { other_wallet.reload.balance.to_f }
            .by(3)
        end
      end

      context 'and amount changes and wallet is present and is being swapped with another' do
        let(:update_params) { { amount: 5, wallet: other_wallet } }

        let(:wallet) { create(:wallet, profile:) }
        let(:other_wallet) { create(:wallet, profile:) }

        it 'updates the profile, and both new and old wallets balances with the amount' do
          expect { update_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(2)
            .and change { wallet.reload.balance.to_f }
            .by(-3)
            .and change { other_wallet.reload.balance.to_f }
            .by(5)
        end
      end

      context 'and amount does not change and wallet is present but it is being set to nil' do
        let(:update_params) { { name: 'Other Name', wallet: nil } }
        let(:wallet) { create(:wallet, profile:) }

        it 'updates only the wallet balance with the inverse of the amount' do
          expect { update_transaction }
            .to not_change { profile.reload.balance_amount.to_f }
            .and change { wallet.reload.balance.to_f }
            .by(-3)
        end
      end

      context 'and amount changes and wallet is present but it is being set to nil' do
        let(:update_params) { { amount: 5, wallet: nil } }
        let(:wallet) { create(:wallet, profile:) }

        it 'updates the profile with the difference, and the wallet balance with the inverse of the amount' do
          expect { update_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(2)
            .and change { wallet.reload.balance.to_f }
            .by(-3)
        end
      end
    end

    context 'when the transaction is being destroyed' do
      subject(:destroy_transaction) { transaction.destroy! }

      let!(:transaction) { create(:transaction, profile: profile, amount: 3, wallet: wallet) }

      context 'and wallet is nil' do
        let(:wallet) { nil }

        it 'updates only the profile balance with the inverse of the amount' do
          expect { destroy_transaction }.to change { profile.reload.balance_amount.to_f }.by(-3)
        end
      end

      context 'and wallet is present' do
        let(:wallet) { create(:wallet, profile:) }

        it 'updates both the profile and wallet balances with the inverse of the amount' do
          expect { destroy_transaction }
            .to change { profile.reload.balance_amount.to_f }
            .by(-3)
            .and change { wallet.reload.balance.to_f }
            .by(-3)
        end
      end
    end
  end
end
