<template>
  <div
    class="WalletBadge badge text-bg-secondary fs-5 py-1 text-decoration-none"
    :title="t('tooltip')"
  >
    <FontAwesomeIcon
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
      required: true,
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
