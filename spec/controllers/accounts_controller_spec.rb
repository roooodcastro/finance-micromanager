# frozen_string_literal: true

RSpec.describe AccountsController do
  let(:user) { create(:user) }

  before do
    sign_in user
    session[:current_account_id] = user.default_account.id
  end

  describe 'GET index', :inertia do
    let!(:account) { create(:account, user:) }

    it 'renders the index component' do
      get :index

      expect_inertia.to render_component('accounts/Index')
                    .and include_camelized_props({ accounts: [user.default_account, account].as_json })
    end
  end

  describe 'GET new', :inertia do
    it 'renders the new component' do
      get :new

      expect_inertia.to render_component('accounts/New')
                    .and include_camelized_props({ account: Account.new.as_json })
    end
  end

  describe 'GET edit', :inertia do
    let!(:account) { create(:account, user:) }

    it 'renders the edit component' do
      get :edit, params: { id: account.id }

      expect_inertia.to render_component('accounts/Edit')
                    .and include_camelized_props({ account: account.as_json })
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    context 'when params are valid and name is blank' do
      let(:params) { { account: { name: nil, currency: 'brl' } } }

      it 'creates the new account' do
        expect { create_request }.to change { Account.count }.by(1)

        new_account = Account.last
        expect(response).to redirect_to(accounts_path)
        expect(new_account.name).to eq('')
        expect(new_account.currency).to eq('brl')
        expect(new_account.user).to eq(user)
      end
    end

    context 'when params are valid and name is present' do
      let(:params) { { account: { name: 'Test', currency: 'brl' } } }

      it 'creates the new account' do
        expect { create_request }.to change { Account.count }.by(1)

        new_account = Account.last
        expect(response).to redirect_to(accounts_path)
        expect(new_account.name).to eq('Test')
        expect(new_account.currency).to eq('brl')
        expect(new_account.user).to eq(user)
      end
    end

    context 'when params are invalid' do
      let(:params) { { account: { name: 'Test', currency: nil } } }

      it 'does not create a new account' do
        expect { create_request }.not_to change { Account.count }

        expect_inertia.to render_component('accounts/New')
        expect(inertia.props.dig(:account, :name)).to eq 'Test'
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:account) { create(:account, user: user, name: nil) }

    context 'when params are valid' do
      let(:params) { { id: account.id, account: { name: 'New Name' } } }

      it 'updates the account' do
        expect { update_request }.not_to change { Account.count }

        expect(response).to redirect_to(accounts_path)
        expect(account.reload.name).to eq('New Name')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: account.id, account: { currency: nil } } }

      it 'does not update the account' do
        expect { update_request }.not_to change { Category.count }

        expect_inertia.to render_component('accounts/Edit')
        expect(inertia.props.dig(:category, :name)).to be_nil
        expect(inertia.props.dig(:category, :currency)).to be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: account.id } }

    let!(:account) { create(:account, user:) }

    it 'disables the account and redirects to index' do
      expect { delete_request }
        .to not_change { Account.count }
        .and change { account.reload.status }
        .from('active')
        .to('disabled')

      expect(response).to redirect_to accounts_path
    end
  end
end
