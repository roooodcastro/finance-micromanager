# frozen_string_literal: true

RSpec.describe SettingsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET show' do
    subject(:show_request) { get :show, format: }

    before { show_request }

    context 'for a HTML request', :inertia do
      let(:format) { :html }

      it 'renders the show component' do
        expect_inertia.to render_component('settings/Show')
      end
    end

    context 'for a JSON request' do
      let(:format) { :json }

      it 'renders the current user as JSON' do
        expect(json_response['user']).to be_present
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) { patch :update, params: }

    context 'when params are valid' do
      let(:params) { { user: { first_name: 'NewFirst' } } }

      it 'updates the user' do
        expect { update_request }.to change { user.reload.first_name }.to('NewFirst')

        expect(json_response).to eq({ 'message' => 'Profile information updated successfully.' })
      end
    end

    context 'when params are invalid' do
      let(:params) { { user: { email: '' } } }

      it 'does not update the user' do
        expect { update_request }.to not_change { user.reload.email }

        expect(json_response).to eq({ 'message' => 'There was an error updating your profile info.' })
      end
    end
  end
end
