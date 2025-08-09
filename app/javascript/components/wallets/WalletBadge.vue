<template>
  <div
    class="WalletBadge badge fs-5 py-1 text-decoration-none"
    :class="{ 'text-bg-secondary': !!wallet, 'text-secondary-emphasis bg-secondary-subtle': !wallet }"
    :title="t('tooltip')"
  >
    <FontAwesomeIcon
      v-if="!!wallet"
      :icon="ICON_WALLETS"
      class="me-2"
    />

    <template v-if="wallet">
      {{ wallet.name }}
    </template>
    <template v-else>
      {{ t('no_wallet') }}
    </template>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { ICON_WALLETS } from '~/utils/Constants.js';
import I18n from '~/utils/I18n.js';

export default {
  components: { FontAwesomeIcon },

  props: {
    wallet: {
      type: Object,
      default: null,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.wallets.wallet_badge');

    return {
      t,
      ICON_WALLETS,
    };
  },
}
</script>

<style lang="scss" scoped>
  .CategoryBadge {
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
}
</style>
