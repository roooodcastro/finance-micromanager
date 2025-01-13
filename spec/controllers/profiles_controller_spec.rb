# frozen_string_literal: true

RSpec.describe ProfilesController do
  let(:user) { create(:user) }

  before do
    sign_in user
    session[:current_profile_id] = user.default_profile.id
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:profile) { user.default_profile }
    let!(:shared_profile) { create(:user).default_profile }

    before { create(:profile_share, profile: shared_profile, user: user) }

    context 'for HTML requests', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        index_request

        expect_inertia.to render_component('profiles/Index')
      end
    end

    context 'for JSON requests' do
      let(:format) { :json }

      let(:expected_profiles) { [profile, shared_profile].map { |profile| profile.as_json(include_wallets: true) } }

      it 'renders the available profiles as JSON' do
        index_request

        expect(json_response['profiles'])
          .to match_array(CamelizeProps.call('profiles' => expected_profiles)['profiles'])
      end
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

        new_profile = Profile.find_by(currency: 'brl')

        expect(json_response).to eq(expected_json.merge('id' => new_profile.id))

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

        new_profile = Profile.find_by(name: 'Test')

        expect(json_response).to eq(expected_json.merge('id' => new_profile.id))

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

  describe 'DELETE destroy', :travel_to_now do
    subject(:delete_request) { delete :destroy, params: { id: profile.id } }

    let!(:profile) { create(:profile, user:) }

    it 'disables the profile and renders json' do
      expect { delete_request }
        .to not_change { Profile.count }
        .and change { profile.reload.disabled_at }
        .from(nil)
        .to(Time.current)

      expect(json_response)
        .to eq('message' => "Profile \"#{profile.display_name}\" was successfully disabled.")
    end
  end

  describe 'PATCH reenable', :travel_to_now do
    subject(:reenable_request) { patch :reenable, params: { id: profile.id } }

    let!(:profile) { create(:profile, :disabled, user:) }

    it 're-enables the profile and renders json' do
      expect { reenable_request }
        .to not_change { Profile.count }
        .and change { profile.reload.disabled_at }
        .from(Time.current)
        .to(nil)

      expect(json_response)
        .to eq('message' => "Profile \"#{profile.display_name}\" was successfully re-enabled.")
    end
  end
end
