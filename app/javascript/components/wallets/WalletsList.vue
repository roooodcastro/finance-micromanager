<template>
  <NoRecordsFound v-if="!wallets.length" />
  <div
    v-else
    class="WalletsList list-group overflow-x-hidden"
  >
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
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
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

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .WalletsList {
    margin-left: -0.5rem;
    margin-right: -0.5rem;
    width: calc(100% + 1rem);
  }
}
</style>
