<template>
  <ListItemDrawerContextMenu class="mx-2 mx-lg-0">
    <template v-slot:actions>
      <WalletActions
        :wallet="wallet"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="WalletListItem d-flex bg-light-subtle align-items-center border bg-white p-2">
        <FontAwesomeIcon
            size="lg"
            class="WalletListItem__currency-icon text-secondary me-3"
            :icon="faIconForCurrency(wallet.currency)"
        />

        <div class="flex-grow-1">
          {{ wallet.name || t('no_name') }}
          <span class="d-block fs-6 text-muted">
            {{ wallet.currencyObject.name }}
          </span>

          <div
              v-if="wallet.shared"
              class="fs-6 text-muted"
          >
            <FontAwesomeIcon
                class=" text-primary me-2"
                icon="share-nodes"
            />
            {{ t('shared_text', { user: wallet.user.fullName }) }}
          </div>
        </div>
        <div class="d-none d-lg-flex">
          <WalletActions :wallet="wallet" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';
import WalletActions from '~/components/wallets/WalletActions.vue';

export default {
  components: {
    FontAwesomeIcon,
    ListItemDrawerContextMenu,
    WalletActions,
  },

  props: {
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return {
      faIconForCurrency,
      t: I18n.scopedTranslator('views.wallets.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.WalletListItem__currency-icon {
  width: 2em;
}

.WalletListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
