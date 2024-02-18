<template>
  <ListItemDrawerContextMenu class="list-group-item overflow-hidden p-0">
    <template v-slot:actions>
      <WalletActions
        :wallet="wallet"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex align-items-center p-2 bg-light-subtle">
        <div class="d-flex flex-column min-width-0">
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

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <WalletActions :wallet="wallet" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import WalletActions from '~/components/wallets/WalletActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    WalletActions,
  },

  props: {
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.wallets.list');
    const isDisabled = computed(() => !!props.wallet.disabledAt);

    return {
      t,
      formatMoney,
      isDisabled,
    };
  }
};
</script>
