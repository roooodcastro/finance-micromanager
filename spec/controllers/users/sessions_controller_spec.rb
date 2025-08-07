# frozen_string_literal: true

RSpec.describe Users::SessionsController do
  let(:user) { create(:user) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET new', :inertia do
    subject(:new_request) { get :new }

    it 'renders the new page' do
      new_request

      expect_inertia.to render_component('users/sessions/New')
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    let(:params) { { user: { email:, password: } } }

    before { create(:user, email: 'user@test.com', password: '123456') }

    context 'when credentials are wrong' do
      let(:email) { 'user@test.com' }
      let(:password) { '123457' }

      it 'does not sign in the user and returns unauthorized' do
        expect(Users::PostLoginActionsService).not_to receive(:call)

        create_request

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when credentials are correct' do
      let(:email) { 'user@test.com' }
      let(:password) { '123456' }

      it 'signs in the user and runs post login actions' do
        expect(Users::PostLoginActionsService).to receive(:call)

        create_request

        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
