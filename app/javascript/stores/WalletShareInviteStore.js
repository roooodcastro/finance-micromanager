import { defineStore } from 'pinia'

import {
  walletShareInvitesReceived as walletShareInvitesReceivedApi,
  walletShareInvitesSent as walletShareInvitesSentApi,
} from '~/api';

export default defineStore('walletShareInvite', {
  state: () => ({
    walletShareInvitesSent: [],
    walletShareInvitesReceived: [],
  }),
  actions: {
    fetchPendingReceivedInvites() {
      walletShareInvitesReceivedApi.index().then((response) => {
        this.walletShareInvitesReceived = response.walletShareInvites;
      });
    },
    fetchPendingSentInvites() {
      walletShareInvitesSentApi.index().then((response) => {
        this.walletShareInvitesSent = response.walletShareInvites;
      });
    },
    acceptPendingReceivedInvite(walletShareInvite) {
      return walletShareInvitesReceivedApi.update({ id: walletShareInvite.id }).then((response) => {
        const index = this.walletShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.walletShareInvite.id;
        });

        this.walletShareInvitesReceived.splice(index, 1, response.walletShareInvite);
      });
    },
    rejectPendingReceivedInvite(walletShareInvite) {
      return walletShareInvitesReceivedApi.destroy({ id: walletShareInvite.id }).then((response) => {
        const index = this.walletShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.walletShareInvite.id;
        });

        this.walletShareInvitesReceived.splice(index, 1, response.walletShareInvite);
      });
    },
    cancelPendingSentInvite(walletShareInvite) {
      return walletShareInvitesSentApi.destroy({ id: walletShareInvite.id }).then((response) => {
        const index = this.walletShareInvitesSent.findIndex((invite) => {
          return invite.id === response.walletShareInvite.id;
        });

        this.walletShareInvitesSent.splice(index, 1, response.walletShareInvite);
      });
    },
    removeWalletShareInviteReceived(inviteReceived) {
      this.walletShareInvitesReceived = this.walletShareInvitesReceived.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
    removeWalletShareInviteSent(inviteReceived) {
      this.walletShareInvitesSent = this.walletShareInvitesSent.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
  }
});
