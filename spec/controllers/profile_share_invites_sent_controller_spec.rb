# frozen_string_literal: true

RSpec.describe ProfileShareInvitesSentController do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    let!(:profile) { create(:profile, user:) }

    context 'when the parameters are valid and this is the first invite to invitee' do
      let(:params) { { profile_share_invite: { invitee_email: 'test@email.com', profile_id: profile.id } } }

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to change { ProfileShareInvite.count }
          .by(1)
          .and have_enqueued_mail(ProfileShareMailer, :profile_share_invite_sent).once

        new_profile_share_invite = ProfileShareInvite.last
        expect(new_profile_share_invite.invitee_email).to eq('test@email.com')
        expect(new_profile_share_invite.profile_id).to eq(profile.id)
        expect(new_profile_share_invite.profile_owner_id).to eq(user.id)

        expect(response).to redirect_to(profiles_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are valid and there is an already cancelled invite to invitee' do
      let(:params) { { profile_share_invite: { invitee_email: 'test@email.com', profile_id: profile.id } } }
      let!(:existing_invite) do
        create(:profile_share_invite, :cancelled, profile_owner: user, profile: profile,
               invitee_email: 'test@email.com')
      end

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to not_change { ProfileShareInvite.count }
          .and have_enqueued_mail(ProfileShareMailer, :profile_share_invite_sent).once

        expect(existing_invite.reload.status).to eq('pending')

        expect(response).to redirect_to(profiles_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are not valid' do
      let(:params) { { profile_share_invite: { invitee_email: '', profile_id: profile.id } } }

      it 'does not send the invite and returns an error message' do
        expect { create_request }
          .to not_change { ProfileShareInvite.count }
          .and not_have_enqueued_mail(ProfileShareMailer, :profile_share_invite_sent).once

        expect(response).to redirect_to(profiles_path)
        expect(flash[:success]).to be_blank
        expect(flash[:error]).to be_present
      end
    end
  end
end
