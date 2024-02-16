# frozen_string_literal: true

RSpec.describe ProfileShareInvitesReceivedController do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET index' do
    subject(:index_request) { get :index }

    let!(:received_profile_share_invite) do
      create(:profile_share_invite, :pending, invitee_email: user.email, invitee: user)
    end

    let(:expected_json) { CamelizeProps.call(profile_share_invites: [received_profile_share_invite.as_json]) }

    it 'renders the invites as JSON' do
      index_request
      expect(json_response).to eq(expected_json)
    end
  end
end
