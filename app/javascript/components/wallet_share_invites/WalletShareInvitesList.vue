<template>
  <div>
    <WalletShareInviteReceived
      v-for="invite in walletShareInvitesReceived"
      :key="`${invite.id}_received_${invite.status}`"
      :wallet-share-invite="invite"
      class="overflow-hidden"
      @accepted="handleReceivedInviteResponse(invite, true)"
      @rejected="handleReceivedInviteResponse(invite, false)"
    />

    <WalletShareInviteSent
      v-for="invite in walletShareInvitesSent"
      :key="`${invite.id}_sent_${invite.status}`"
      :wallet-share-invite="invite"
      class="overflow-hidden"
      @cancelled="handleSentInviteCancellation(invite)"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useWalletStore from '~/stores/WalletStore.js';
import useWalletShareInviteStore from '~/stores/WalletShareInviteStore.js';
import WalletShareInviteReceived from '~/components/wallet_share_invites/WalletShareInviteReceived.vue';
import WalletShareInviteSent from '~/components/wallet_share_invites/WalletShareInviteSent.vue';

export default {
  components: {
    WalletShareInviteReceived,
    WalletShareInviteSent,
  },

  setup() {
    const walletShareInviteStore = useWalletShareInviteStore();
    const walletStore = useWalletStore();
    const { walletShareInvitesReceived, walletShareInvitesSent } = storeToRefs(walletShareInviteStore);
    walletShareInviteStore.fetchPendingReceivedInvites();
    walletShareInviteStore.fetchPendingSentInvites();

    const handleReceivedInviteResponse = (walletShareInvite, accepted) => {
      if (accepted) {
        walletShareInviteStore.acceptPendingReceivedInvite(walletShareInvite).then(() => {
          walletStore.fetchAvailableWallets();
          setTimeout(() => {
            walletShareInviteStore.removeWalletShareInviteReceived(walletShareInvite);
          }, 5000);
        });
      } else {
        walletShareInviteStore.rejectPendingReceivedInvite(walletShareInvite).then(() => {
          setTimeout(() => {
            walletShareInviteStore.removeWalletShareInviteReceived(walletShareInvite);
          }, 5000);
        });
      }
    };

    const handleSentInviteCancellation = (walletShareInvite) => {
      walletShareInviteStore.cancelPendingSentInvite(walletShareInvite).then(() => {
        setTimeout(() => {
          walletShareInviteStore.removeWalletShareInviteSent(walletShareInvite);
        }, 5000);
      });
    };

    return {
      walletShareInvitesReceived,
      walletShareInvitesSent,
      handleReceivedInviteResponse,
      handleSentInviteCancellation,
    };
  },
};
</script>
