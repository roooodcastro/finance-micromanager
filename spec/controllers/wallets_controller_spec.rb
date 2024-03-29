# frozen_string_literal: true

RSpec.describe WalletsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    let!(:wallet) { create(:wallet, profile:) }

    context 'when the format is HTML', :inertia do
      it 'renders the index component' do
        get :index, format: :html

        expect_inertia.to render_component('wallets/Index')
                      .and include_props({ wallets: [CamelizeProps.call(wallet.as_json)] })
      end
    end

    context 'when the format is JSON' do
      let(:expected_props) { CamelizeProps.call(wallets: [wallet.as_json]) }

      it 'renders the wallets as json' do
        get :index, format: :json

        expect(json_response).to eq(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    context 'when params are valid' do
      let(:params) { { wallet: { name: 'Test' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => "Wallet \"#{Wallet.first.name}\" was successfully created.")
      end

      it 'creates the new wallet and renders json' do
        expect { create_request }.to change { Wallet.count }.by(1)

        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { wallet: { name: '' } } }

      let(:expected_json) { CamelizeProps.call('message' => 'Wallet could not be created: Name can\'t be blank') }

      it 'does not create a new wallet' do
        expect { create_request }.not_to change { Wallet.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) { patch :update, params: }

    let!(:wallet) { create(:wallet, profile: profile, name: 'ThisWallet') }

    let(:expected_json) do
      CamelizeProps.call('message' => "Wallet \"#{wallet.reload.name}\" was successfully updated.")
    end

    context 'when params are valid' do
      let(:params) { { id: wallet.id, wallet: { name: 'New Name' } } }

      it 'updates the wallet' do
        expect { update_request }.to not_change { Wallet.count }.and change { wallet.reload.name }.to('New Name')

        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: wallet.id, wallet: { name: '' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => "Wallet \"ThisWallet\" could not be updated: Name can't be blank")
      end

      it 'does not update the wallet' do
        expect { update_request }.to not_change { Wallet.count }.and not_change { wallet.reload.name }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now do
    subject(:delete_request) { delete :destroy, params: { id: wallet.id } }

    let!(:wallet) { create(:wallet, profile:) }

    context 'when the wallet can be disabled' do
      let(:expected_json) { { 'message' => "Wallet \"#{wallet.name}\" was successfully disabled." } }

      it 'disables the wallet and renders json success' do
        expect { delete_request }
          .to not_change { Wallet.count }
          .and change { wallet.reload.disabled_at }
          .to(Time.current)
          .and change { wallet.disabled_by }
          .to(user)

        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the wallet cannot be disabled' do
      let!(:wallet) { create(:wallet, profile: profile, balance: 1) }

      it 'does not disable the wallet and renders json error' do
        expect { delete_request }
          .to not_change { Wallet.count }
          .and not_change { wallet.reload.disabled_at }
          .and not_change { wallet.disabled_by }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['message']).to be_present
      end
    end
  end

  describe 'PATCH reenable' do
    subject(:reenable_request) { patch :reenable, params: { id: wallet.id } }

    let!(:wallet) { create(:wallet, :disabled, profile:) }
    let(:expected_json) { { 'message' => "Wallet \"#{wallet.name}\" was successfully re-enabled." } }

    it 'disables the wallet and renders json' do
      expect { reenable_request }
        .to not_change { Wallet.count }
        .and change { wallet.reload.disabled_at }
        .to(nil)
        .and change { wallet.disabled_by }
        .to(nil)

      expect(json_response).to eq(CamelizeProps.call(expected_json))
    end
  end
end
