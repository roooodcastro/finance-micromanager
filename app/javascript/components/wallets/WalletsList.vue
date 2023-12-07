<template>
  <div class="list-group">
    <template
      v-for="wallet in wallets"
      :key="`${wallet.id}_${wallet.updatedAt}`"
    >
      <WalletListItem :wallet="wallet" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useWalletStore from '~/stores/WalletStore.js';

import WalletListItem from '~/components/wallets/WalletListItem.vue';

export default {
  components: {
    WalletListItem,
  },

  setup() {
    const walletStore = useWalletStore();

    const { wallets } = storeToRefs(walletStore);

    return {
      wallets,
    };
  },
};
</script>
