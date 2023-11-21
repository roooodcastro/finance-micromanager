<template>
  <div class="WalletsList">
    <WalletListItem
      v-for="wallet in walletsFromStore"
      :key="wallet.id"
      :wallet="wallet"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore';

import WalletListItem from '~/components/wallets/WalletListItem.vue';

export default {
  components: {
    WalletListItem,
  },

  props: {
    wallets: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const walletStore = useWalletStore();

    const { availableWallets: walletsFromStore } = storeToRefs(walletStore);
    walletsFromStore.value = props.wallets;

    return {
      t: I18n.scopedTranslator('views.wallets.index'),
      walletsFromStore,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .WalletsList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
