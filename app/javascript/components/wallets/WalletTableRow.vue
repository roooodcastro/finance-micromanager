<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span :class="{ 'text-muted': isDisabled }">
        {{ wallet.name }}
      </span>
      <span
        v-if="isDisabled"
        class="badge text-bg-danger"
      >
        {{ t('disabled') }}
      </span>
    </div>
  </div>

  <div class="GridRow__right">
    <div class="text-end">
      {{ formatMoney(wallet.balance) }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  props: {
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.components.wallets_list');
    const isDisabled = computed(() => !!props.wallet.disabledAt);

    return {
      t,
      formatMoney,
      isDisabled,
    };
  }
};
</script>
