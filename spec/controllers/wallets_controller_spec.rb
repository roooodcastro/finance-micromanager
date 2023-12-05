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

    let(:expected_props) { CamelizeProps.call(wallets: [wallet.as_json]) }

    it 'renders the wallets as json' do
      get :index

      expect(json_response).to eq(expected_props)
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
end
