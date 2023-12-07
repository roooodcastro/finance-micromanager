<template>
  <ListItemDrawerContextMenu class="list-group-item p-0">
    <template v-slot:actions>
      <WalletActions
        :wallet="wallet"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div
        class="d-flex align-items-center py-2 ps-2"
        :class="{ 'fst-italic bg-danger-subtle': isDisabled, 'bg-light-subtle': !isDisabled }"
      >
        <span>
          {{ wallet.name }}
          <template v-if="isDisabled">
            ({{ t('disabled') }})
          </template>
        </span>

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
      isDisabled,
    };
  }
};
</script>
