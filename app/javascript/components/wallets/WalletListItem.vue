<template>
  <ListItem
    :record="wallet"
    :actions-component="WalletActions"
  >
    <div class="d-flex flex-column min-width-0 p-2">
      <span class="d-flex align-items-center gap-2">
        <span
          v-if="isDisabled"
          class="badge text-bg-danger"
        >
          {{ t('disabled') }}
        </span>

        {{ wallet.name }}
        <template v-if="isDisabled">
          ({{ t('disabled') }})
        </template>
      </span>
      <span class="fs-6 text-muted text-truncate">
        {{ t('balance') }}:
        {{ formatMoney(wallet.balance) }}
      </span>
    </div>
  </ListItem>
</template>

<script>
import { computed, markRaw } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import WalletActions from '~/components/wallets/WalletActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    markRaw(WalletActions);
    const t = I18n.scopedTranslator('views.wallets.list');
    const isDisabled = computed(() => !!props.wallet.disabledAt);

    return {
      t,
      formatMoney,
      isDisabled,
      WalletActions,
    };
  }
};
</script>
