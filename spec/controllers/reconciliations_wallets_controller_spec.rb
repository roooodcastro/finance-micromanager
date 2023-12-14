# frozen_string_literal: true

RSpec.describe ReconciliationsWalletsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }
  let(:wallet) { create(:wallet, profile:) }
  let(:reconciliation) { create(:reconciliation, profile:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
    allow(Current).to receive(:profile).and_return(profile)
  end

  describe 'POST create' do
    subject(:create_request) do
      post :create, format: :json, params: {
        reconciliation_id:     reconciliation.id,
        id:                    id,
        reconciliation_wallet: reconciliation_wallet_params
      }
    end

    let(:reconciliation_wallet_params) { { wallet_id: wallet.id, balance_amount: 3.14 } }

    context 'when the record does not yet exist and wallet is valid' do
      let(:id) { nil }

      it 'creates a new reconciliation wallet and assigns all correct values to it' do
        expect { create_request }.to change { ReconciliationWallet.count }.by(1)

        new_record = ReconciliationWallet.last
        expect(new_record.wallet).to eq(wallet)
        expect(new_record.reconciliation).to eq(reconciliation)
        expect(new_record.balance_amount.to_f).to eq(3.14)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the record does not yet exist and wallet belongs to the wrong profile' do
      let(:id) { nil }
      let(:other_wallet) { create(:wallet) }
      let(:reconciliation_wallet_params) { { wallet_id: other_wallet.id, balance_amount: 3.14 } }

      it 'does not create a new reconciliation wallet and instead returns a 404 error' do
        expect { create_request }.to not_change { ReconciliationWallet.count }

        expect(response).to have_http_status(:not_found)
        expect(json_response).to eq(
          'message' => 'Wallet balance could not be updated because a record could not be found. Please try again.'
        )
      end
    end

    context 'when the record already exists' do
      let!(:reconciliation_wallet) { create(:reconciliation_wallet, reconciliation:) }
      let(:id) { reconciliation_wallet.id }

      it 'updates the existing reconciliation wallet and assigns all correct values to it' do
        expect { create_request }
          .to not_change { ReconciliationWallet.count }
          .and change { reconciliation_wallet.reload.balance_amount.to_f }
          .to(3.14)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the record already exists but the ID is not passed correctly' do
      let!(:reconciliation_wallet) { create(:reconciliation_wallet, reconciliation:, wallet:) }
      let(:id) { nil }

      it 'does not update the existing reconciliation wallet and returns an error message' do
        expect { create_request }
          .to not_change { ReconciliationWallet.count }
          .and not_change { reconciliation_wallet.reload.balance_amount }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq('message' => 'Wallet balance could not be updated: Wallet has already been taken')
      end
    end
  end
end
