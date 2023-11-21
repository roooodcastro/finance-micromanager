<template>
  <div>
    <AccountShareInviteReceived
      v-for="invite in accountShareInvitesReceived"
      :key="`${invite.id}_received_${invite.status}`"
      :account-share-invite="invite"
      class="overflow-hidden"
      @accepted="handleReceivedInviteResponse(invite, true)"
      @rejected="handleReceivedInviteResponse(invite, false)"
    />

    <AccountShareInviteSent
      v-for="invite in accountShareInvitesSent"
      :key="`${invite.id}_sent_${invite.status}`"
      :account-share-invite="invite"
      class="overflow-hidden"
      @cancelled="handleSentInviteCancellation(invite)"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useAccountStore from '~/stores/AccountStore.js';
import useAccountShareInviteStore from '~/stores/AccountShareInviteStore.js';
import AccountShareInviteReceived from '~/components/account_share_invites/AccountShareInviteReceived.vue';
import AccountShareInviteSent from '~/components/account_share_invites/AccountShareInviteSent.vue';

export default {
  components: {
    AccountShareInviteReceived,
    AccountShareInviteSent,
  },

  setup() {
    const accountShareInviteStore = useAccountShareInviteStore();
    const accountStore = useAccountStore();
    const { accountShareInvitesReceived, accountShareInvitesSent } = storeToRefs(accountShareInviteStore);
    accountShareInviteStore.fetchPendingReceivedInvites();
    accountShareInviteStore.fetchPendingSentInvites();

    const handleReceivedInviteResponse = (accountShareInvite, accepted) => {
      if (accepted) {
        accountShareInviteStore.acceptPendingReceivedInvite(accountShareInvite).then(() => {
          accountStore.fetchAvailableAccounts();
          setTimeout(() => {
            accountShareInviteStore.removeAccountShareInviteReceived(accountShareInvite);
          }, 5000);
        });
      } else {
        accountShareInviteStore.rejectPendingReceivedInvite(accountShareInvite).then(() => {
          setTimeout(() => {
            accountShareInviteStore.removeAccountShareInviteReceived(accountShareInvite);
          }, 5000);
        });
      }
    };

    const handleSentInviteCancellation = (accountShareInvite) => {
      accountShareInviteStore.cancelPendingSentInvite(accountShareInvite).then(() => {
        setTimeout(() => {
          accountShareInviteStore.removeAccountShareInviteSent(accountShareInvite);
        }, 5000);
      });
    };

    return {
      accountShareInvitesReceived,
      accountShareInvitesSent,
      handleReceivedInviteResponse,
      handleSentInviteCancellation,
    };
  },
};
</script>
