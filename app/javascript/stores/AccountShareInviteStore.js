import { defineStore } from 'pinia'

import {
  accountShareInvitesReceived as accountShareInvitesReceivedApi,
} from '~/api';

export default defineStore('accountShareInvite', {
  state: () => ({
    accountShareInvitesGiven: [],
    accountShareInvitesReceived: [],
  }),
  actions: {
    fetchPendingReceivedInvites() {
      accountShareInvitesReceivedApi.index().then((response) => {
        this.accountShareInvitesReceived = response.accountShareInvites;
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
    removeAccountShareInviteReceived(inviteReceived) {
      this.accountShareInvitesReceived = this.accountShareInvitesReceived.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
  }
});
