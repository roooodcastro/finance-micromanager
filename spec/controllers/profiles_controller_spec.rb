# frozen_string_literal: true

RSpec.describe ProfilesController do
  let(:user) { create(:user) }

  before do
    sign_in user
    session[:current_profile_id] = user.default_profile.id
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'GET index', :inertia do
    let!(:profile) { create(:profile, user:) }

    let!(:shared_profile) do
      new_profile = create(:profile)
      create(:profile_share, profile: new_profile, user: user)
      new_profile
    end

    it 'renders the index component, returning all available profiles' do
      get :index

      expect_inertia
        .to render_component('profiles/Index')
        .and include_camelized_props({ profiles: [user.default_profile, profile, shared_profile].as_json })
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    context 'when params are valid and name is blank' do
      let(:params) { { profile: { name: nil, currency: 'brl' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => 'Profile "Brazilian Real" was successfully created.')
      end

      it 'creates the new profile' do
        expect { create_request }.to change { Profile.count }.by(1)

        expect(json_response).to eq(expected_json)

        new_profile = Profile.find_by(currency: 'brl')
        expect(new_profile.name).to eq('')
        expect(new_profile.user).to eq(user)
      end
    end

    context 'when params are valid and name is present' do
      let(:params) { { profile: { name: 'Test', currency: 'brl' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => 'Profile "Test" was successfully created.')
      end

      it 'creates the new profile' do
        expect { create_request }.to change { Profile.count }.by(1)

        expect(json_response).to eq(expected_json)

        new_profile = Profile.find_by(name: 'Test')
        expect(new_profile.name).to eq('Test')
        expect(new_profile.currency).to eq('brl')
        expect(new_profile.user).to eq(user)
      end
    end

    context 'when params are invalid' do
      let(:params) { { profile: { name: 'Test', status: nil } } }

      let(:expected_json) { CamelizeProps.call('message' => 'Profile could not be created: Currency can\'t be blank') }

      it 'does not create a new profile' do
        expect { create_request }.not_to change { Profile.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:profile) { create(:profile, user: user, name: nil) }

    context 'when params are valid and profile is owned by the user' do
      let(:params) { { id: profile.id, profile: { name: 'New Name' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => 'Profile "New Name" was successfully updated.')
      end

      it 'updates the profile' do
        expect { update_request }.not_to change { Profile.count }
        expect(json_response).to eq(expected_json)
        expect(profile.reload.name).to eq('New Name')
      end
    end

    context 'when params are valid and profile is shared with the user' do
      let!(:profile) do
        new_profile = create(:profile, name: nil)
        create(:profile_share, profile: new_profile, user: user)
        new_profile
      end

      let(:params) { { id: profile.id, profile: { name: 'New Name' } } }

      let(:expected_json) do
        CamelizeProps.call('message' => 'Profile "New Name" was successfully updated.')
      end

      it 'updates the profile' do
        expect { update_request }.not_to change { Profile.count }
        expect(json_response).to eq(expected_json)
        expect(profile.reload.name).to eq('New Name')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: profile.id, profile: { currency: nil } } }

      let(:expected_json) do
        CamelizeProps.call('message' => 'Profile "" could not be updated: Currency can\'t be blank, Currency is ' \
                                        'not included in the list')
      end

      it 'does not update the profile' do
        expect { update_request }.not_to change { Profile.count }

        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: profile.id } }

    let!(:profile) { create(:profile, user:) }

    it 'disables the profile and renders json' do
      expect { delete_request }
        .to not_change { Profile.count }
        .and change { profile.reload.status }
        .from('active')
        .to('disabled')

      expect(json_response)
        .to eq('message' => "Profile \"#{profile.display_name}\" was successfully disabled.")
    end
  end
end
