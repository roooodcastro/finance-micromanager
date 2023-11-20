<template>
  <div>
    <AccountShareInvite
      v-for="invite in accountShareInvitesReceived"
      :key="`${invite.id}_${invite.status}`"
      :account-share-invite="invite"
      style="overflow: hidden"
      @accepted="handleInviteResponse(invite, true)"
      @rejected="handleInviteResponse(invite, false)"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useAccountStore from '~/stores/AccountStore.js';
import useAccountShareInviteStore from '~/stores/AccountShareInviteStore.js';
import AccountShareInvite from '~/components/account_share_invites/AccountShareInvite.vue';

export default {
  components: {
    AccountShareInvite
  },

  setup() {
    const accountShareInviteStore = useAccountShareInviteStore();
    const accountStore = useAccountStore();
    const { accountShareInvitesReceived } = storeToRefs(accountShareInviteStore);
    accountShareInviteStore.fetchPendingReceivedInvites();

    const handleInviteResponse = (accountShareInvite, accepted) => {
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

    return {
      accountShareInvitesReceived,
      handleInviteResponse,
    };
  },
};
</script>
