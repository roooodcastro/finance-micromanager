# frozen_string_literal: true

RSpec.describe WalletsController do
  let(:user) { create(:user) }

  before do
    sign_in user
    session[:current_wallet_id] = user.default_wallet.id
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'GET index', :inertia do
    let!(:wallet) { create(:wallet, user:) }

    let!(:shared_wallet) do
      new_wallet = create(:wallet)
      create(:wallet_share, wallet: new_wallet, user: user)
      new_wallet
    end

    it 'renders the index component, returning all available wallets' do
      get :index

      expect_inertia.to render_component('wallets/Index')
                    .and include_camelized_props({ wallets: [user.default_wallet, wallet, shared_wallet].as_json })
    end
  end

  describe 'GET new', :inertia do
    it 'renders the new component' do
      get :new

      expect_inertia.to render_component('wallets/New')
                    .and include_camelized_props({ wallet: Wallet.new.as_json })
    end
  end

  describe 'GET edit', :inertia do
    let!(:wallet) { create(:wallet, user:) }

    context 'for an wallet owned by the user' do
      it 'renders the edit component' do
        get :edit, params: { id: wallet.id }

        expect_inertia.to render_component('wallets/Edit')
                      .and include_camelized_props({ wallet: wallet.as_json })
      end
    end

    context 'for an wallet shared with the user' do
      let!(:wallet) do
        new_wallet = create(:wallet)
        create(:wallet_share, wallet: new_wallet, user: user)
        new_wallet
      end

      it 'renders the edit component' do
        get :edit, params: { id: wallet.id }

        expect_inertia.to render_component('wallets/Edit')
                      .and include_camelized_props({ wallet: wallet.as_json })
      end
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    context 'when params are valid and name is blank' do
      let(:params) { { wallet: { name: nil, currency: 'brl' } } }

      it 'creates the new wallet' do
        expect { create_request }.to change { Wallet.count }.by(1)

        new_wallet = Wallet.last
        expect(response).to redirect_to(wallets_path)
        expect(new_wallet.name).to eq('')
        expect(new_wallet.currency).to eq('brl')
        expect(new_wallet.user).to eq(user)
      end
    end

    context 'when params are valid and name is present' do
      let(:params) { { wallet: { name: 'Test', currency: 'brl' } } }

      it 'creates the new wallet' do
        expect { create_request }.to change { Wallet.count }.by(1)

        new_wallet = Wallet.last
        expect(response).to redirect_to(wallets_path)
        expect(new_wallet.name).to eq('Test')
        expect(new_wallet.currency).to eq('brl')
        expect(new_wallet.user).to eq(user)
      end
    end

    context 'when params are invalid' do
      let(:params) { { wallet: { name: 'Test', currency: nil } } }

      it 'does not create a new wallet' do
        expect { create_request }.not_to change { Wallet.count }

        expect_inertia.to render_component('wallets/New')
        expect(inertia.props.dig(:wallet, :name)).to eq 'Test'
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:wallet) { create(:wallet, user: user, name: nil) }

    context 'when params are valid and wallet is owned by the user' do
      let(:params) { { id: wallet.id, wallet: { name: 'New Name' } } }

      it 'updates the wallet' do
        expect { update_request }.not_to change { Wallet.count }

        expect(response).to redirect_to(wallets_path)
        expect(wallet.reload.name).to eq('New Name')
      end
    end

    context 'when params are valid and wallet is shared with the user' do
      let!(:wallet) do
        new_wallet = create(:wallet, name: nil)
        create(:wallet_share, wallet: new_wallet, user: user)
        new_wallet
      end

      let(:params) { { id: wallet.id, wallet: { name: 'New Name' } } }

      it 'updates the wallet' do
        expect { update_request }.not_to change { Wallet.count }

        expect(response).to redirect_to(wallets_path)
        expect(wallet.reload.name).to eq('New Name')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: wallet.id, wallet: { currency: nil } } }

      it 'does not update the wallet' do
        expect { update_request }.not_to change { Wallet.count }

        expect_inertia.to render_component('wallets/Edit')
        expect(inertia.props.dig(:wallet, :name)).to be_nil
        expect(inertia.props.dig(:wallet, :currency)).to eq('')
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: wallet.id } }

    let!(:wallet) { create(:wallet, user:) }

    it 'disables the wallet and redirects to index' do
      expect { delete_request }
        .to not_change { Wallet.count }
        .and change { wallet.reload.status }
        .from('active')
        .to('disabled')

      expect(response).to redirect_to wallets_path
    end
  end
end
