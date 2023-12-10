import { defineStore } from 'pinia'

import {
  profileShareInvitesReceived as profileShareInvitesReceivedApi,
  profileShareInvitesSent as profileShareInvitesSentApi,
} from '~/api/all.js';

export default defineStore('profileShareInvite', {
  state: () => ({
    profileShareInvitesSent: [],
    profileShareInvitesReceived: [],
  }),
  actions: {
    fetchPendingReceivedInvites() {
      profileShareInvitesReceivedApi.index().then((response) => {
        this.profileShareInvitesReceived = response.profileShareInvites;
      });
    },
    fetchPendingSentInvites() {
      profileShareInvitesSentApi.index().then((response) => {
        this.profileShareInvitesSent = response.profileShareInvites;
      });
    },
    acceptPendingReceivedInvite(profileShareInvite) {
      return profileShareInvitesReceivedApi.update({ id: profileShareInvite.id }).then((response) => {
        const index = this.profileShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.profileShareInvite.id;
        });

        this.profileShareInvitesReceived.splice(index, 1, response.profileShareInvite);
      });
    },
    rejectPendingReceivedInvite(profileShareInvite) {
      return profileShareInvitesReceivedApi.destroy({ id: profileShareInvite.id }).then((response) => {
        const index = this.profileShareInvitesReceived.findIndex((invite) => {
          return invite.id === response.profileShareInvite.id;
        });

        this.profileShareInvitesReceived.splice(index, 1, response.profileShareInvite);
      });
    },
    cancelPendingSentInvite(profileShareInvite) {
      return profileShareInvitesSentApi.destroy({ id: profileShareInvite.id }).then((response) => {
        const index = this.profileShareInvitesSent.findIndex((invite) => {
          return invite.id === response.profileShareInvite.id;
        });

        this.profileShareInvitesSent.splice(index, 1, response.profileShareInvite);
      });
    },
    removeProfileShareInviteReceived(inviteReceived) {
      this.profileShareInvitesReceived = this.profileShareInvitesReceived.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
    removeProfileShareInviteSent(inviteReceived) {
      this.profileShareInvitesSent = this.profileShareInvitesSent.filter((invite) => {
        return invite.id !== inviteReceived.id;
      });
    },
  }
});
