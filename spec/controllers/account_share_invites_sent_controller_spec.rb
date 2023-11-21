# frozen_string_literal: true

RSpec.describe AccountShareInvitesSentController do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    let!(:account) { create(:account, user:) }

    context 'when the parameters are valid and this is the first invite to invitee' do
      let(:params) { { account_share_invite: { invitee_email: 'test@email.com', account_id: account.id } } }

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to change { AccountShareInvite.count }
          .by(1)
          .and have_enqueued_mail(AccountShareMailer, :account_share_invite_sent).once

        new_account_share_invite = AccountShareInvite.last
        expect(new_account_share_invite.invitee_email).to eq('test@email.com')
        expect(new_account_share_invite.account_id).to eq(account.id)
        expect(new_account_share_invite.account_owner_id).to eq(user.id)

        expect(response).to redirect_to(accounts_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are valid and there is an already cancelled invite to invitee' do
      let(:params) { { account_share_invite: { invitee_email: 'test@email.com', account_id: account.id } } }
      let!(:existing_invite) do
        create(:account_share_invite, :cancelled, account_owner: user, account: account,
               invitee_email: 'test@email.com')
      end

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to not_change { AccountShareInvite.count }
          .and have_enqueued_mail(AccountShareMailer, :account_share_invite_sent).once

        expect(existing_invite.reload.status).to eq('pending')

        expect(response).to redirect_to(accounts_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are not valid' do
      let(:params) { { account_share_invite: { invitee_email: '', account_id: account.id } } }

      it 'does not send the invite and returns an error message' do
        expect { create_request }
          .to not_change { AccountShareInvite.count }
          .and not_have_enqueued_mail(AccountShareMailer, :account_share_invite_sent).once

        expect(response).to redirect_to(accounts_path)
        expect(flash[:success]).to be_blank
        expect(flash[:error]).to be_present
      end
    end
  end
end
