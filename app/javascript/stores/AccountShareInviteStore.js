import { defineStore } from 'pinia'

import {
  accountShareInvitesReceived as accountShareInvitesReceivedApi,
  accountShareInvitesSent as accountShareInvitesSentApi,
} from '~/api';

export default defineStore('accountShareInvite', {
  state: () => ({
    accountShareInvitesSent: [],
    accountShareInvitesReceived: [],
  }),
  actions: {
    fetchPendingReceivedInvites() {
      accountShareInvitesReceivedApi.index().then((response) => {
        this.accountShareInvitesReceived = response.accountShareInvites;
      });
    },
    fetchPendingSentInvites() {
      accountShareInvitesSentApi.index().then((response) => {
        this.accountShareInvitesSent = response.accountShareInvites;
      });
    },
    acceptPendingReceivedInvite(accountShareInvite) {
      return accountShareInvitesReceivedApi.update({ id: accountShareInvite.id }).then((response) => {
        const index = this.accountShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.accountShareInvite.id;
        });

        this.accountShareInvitesReceived.splice(index, 1, response.accountShareInvite);
      });
    },
    rejectPendingReceivedInvite(accountShareInvite) {
      return accountShareInvitesReceivedApi.destroy({ id: accountShareInvite.id }).then((response) => {
        const index = this.accountShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.accountShareInvite.id;
        });

        this.accountShareInvitesReceived.splice(index, 1, response.accountShareInvite);
      });
    },
    cancelPendingSentInvite(accountShareInvite) {
      return accountShareInvitesSentApi.destroy({ id: accountShareInvite.id }).then((response) => {
        const index = this.accountShareInvitesSent.findIndex((invite) => {
          return invite.id === response.accountShareInvite.id;
        });

        this.accountShareInvitesSent.splice(index, 1, response.accountShareInvite);
      });
    },
    removeAccountShareInviteReceived(inviteReceived) {
      this.accountShareInvitesReceived = this.accountShareInvitesReceived.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
    removeAccountShareInviteSent(inviteReceived) {
      this.accountShareInvitesSent = this.accountShareInvitesSent.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
  }
});
