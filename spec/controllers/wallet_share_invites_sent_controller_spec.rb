# frozen_string_literal: true

RSpec.describe WalletShareInvitesSentController do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    let!(:wallet) { create(:wallet, user:) }

    context 'when the parameters are valid and this is the first invite to invitee' do
      let(:params) { { wallet_share_invite: { invitee_email: 'test@email.com', wallet_id: wallet.id } } }

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to change { WalletShareInvite.count }
          .by(1)
          .and have_enqueued_mail(WalletShareMailer, :wallet_share_invite_sent).once

        new_wallet_share_invite = WalletShareInvite.last
        expect(new_wallet_share_invite.invitee_email).to eq('test@email.com')
        expect(new_wallet_share_invite.wallet_id).to eq(wallet.id)
        expect(new_wallet_share_invite.wallet_owner_id).to eq(user.id)

        expect(response).to redirect_to(wallets_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are valid and there is an already cancelled invite to invitee' do
      let(:params) { { wallet_share_invite: { invitee_email: 'test@email.com', wallet_id: wallet.id } } }
      let!(:existing_invite) do
        create(:wallet_share_invite, :cancelled, wallet_owner: user, wallet: wallet,
               invitee_email: 'test@email.com')
      end

      it 'sends the invite and returns a success message' do
        expect { create_request }
          .to not_change { WalletShareInvite.count }
          .and have_enqueued_mail(WalletShareMailer, :wallet_share_invite_sent).once

        expect(existing_invite.reload.status).to eq('pending')

        expect(response).to redirect_to(wallets_path)
        expect(flash[:success]).to be_present
        expect(flash[:error]).to be_blank
      end
    end

    context 'when the parameters are not valid' do
      let(:params) { { wallet_share_invite: { invitee_email: '', wallet_id: wallet.id } } }

      it 'does not send the invite and returns an error message' do
        expect { create_request }
          .to not_change { WalletShareInvite.count }
          .and not_have_enqueued_mail(WalletShareMailer, :wallet_share_invite_sent).once

        expect(response).to redirect_to(wallets_path)
        expect(flash[:success]).to be_blank
        expect(flash[:error]).to be_present
      end
    end
  end
end
