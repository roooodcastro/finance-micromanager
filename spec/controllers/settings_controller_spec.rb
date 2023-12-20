# frozen_string_literal: true

RSpec.describe SettingsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET show', :inertia do
    it 'renders the show component' do
      get :show, format: :html

      expect_inertia.to render_component('settings/Show')
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    context 'when params are valid' do
      let(:params) { { user: { first_name: 'NewFirst' } } }

      it 'updates the user' do
        expect { update_request }.to change { user.reload.first_name }.to('NewFirst')

        expect(response).to redirect_to(setting_path)
      end
    end

    context 'when params are invalid' do
      let(:params) { { user: { email: '' } } }

      it 'does not update the user' do
        expect { update_request }.to not_change { user.reload.email }

        expect_inertia.to render_component('settings/Show')
      end
    end
  end
end
