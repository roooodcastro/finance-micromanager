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

      expect_inertia.to render_component('profiles/Index')
                    .and include_camelized_props({ profiles: [user.default_profile, profile, shared_profile].as_json })
    end
  end

  describe 'GET new', :inertia do
    it 'renders the new component' do
      get :new

      expect_inertia.to render_component('profiles/New')
                    .and include_camelized_props({ profile: Profile.new.as_json })
    end
  end

  describe 'GET edit', :inertia do
    let!(:profile) { create(:profile, user:) }

    context 'for an profile owned by the user' do
      it 'renders the edit component' do
        get :edit, params: { id: profile.id }

        expect_inertia.to render_component('profiles/Edit')
                      .and include_camelized_props({ profile: profile.as_json })
      end
    end

    context 'for an profile shared with the user' do
      let!(:profile) do
        new_profile = create(:profile)
        create(:profile_share, profile: new_profile, user: user)
        new_profile
      end

      it 'renders the edit component' do
        get :edit, params: { id: profile.id }

        expect_inertia.to render_component('profiles/Edit')
                      .and include_camelized_props({ profile: profile.as_json })
      end
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    context 'when params are valid and name is blank' do
      let(:params) { { profile: { name: nil, currency: 'brl' } } }

      it 'creates the new profile' do
        expect { create_request }.to change { Profile.count }.by(1)

        new_profile = Profile.last
        expect(response).to redirect_to(profiles_path)
        expect(new_profile.name).to eq('')
        expect(new_profile.currency).to eq('brl')
        expect(new_profile.user).to eq(user)
      end
    end

    context 'when params are valid and name is present' do
      let(:params) { { profile: { name: 'Test', currency: 'brl' } } }

      it 'creates the new profile' do
        expect { create_request }.to change { Profile.count }.by(1)

        new_profile = Profile.last
        expect(response).to redirect_to(profiles_path)
        expect(new_profile.name).to eq('Test')
        expect(new_profile.currency).to eq('brl')
        expect(new_profile.user).to eq(user)
      end
    end

    context 'when params are invalid' do
      let(:params) { { profile: { name: 'Test', currency: nil } } }

      it 'does not create a new profile' do
        expect { create_request }.not_to change { Profile.count }

        expect_inertia.to render_component('profiles/New')
        expect(inertia.props.dig(:profile, :name)).to eq 'Test'
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:profile) { create(:profile, user: user, name: nil) }

    context 'when params are valid and profile is owned by the user' do
      let(:params) { { id: profile.id, profile: { name: 'New Name' } } }

      it 'updates the profile' do
        expect { update_request }.not_to change { Profile.count }

        expect(response).to redirect_to(profiles_path)
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

      it 'updates the profile' do
        expect { update_request }.not_to change { Profile.count }

        expect(response).to redirect_to(profiles_path)
        expect(profile.reload.name).to eq('New Name')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: profile.id, profile: { currency: nil } } }

      it 'does not update the profile' do
        expect { update_request }.not_to change { Profile.count }

        expect_inertia.to render_component('profiles/Edit')
        expect(inertia.props.dig(:profile, :name)).to be_nil
        expect(inertia.props.dig(:profile, :currency)).to eq('')
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
        .to eq('profileId' => profile.id, 'message' => "Profile \"#{profile.display_name}\" was successfully disabled.")
    end
  end
end
