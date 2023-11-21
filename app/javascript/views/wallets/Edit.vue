<template>
  <div>
    <PageHeader :page-title="t('edit_title', { wallet: wallet.displayName })" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <WalletForm :wallet="wallet" />
      </div>
    </div>
  </div>
</template>

<script>
import { wallets } from '~/api';
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';
import WalletForm from '~/components/wallets/WalletForm.vue';

export default {
  components: {
    WalletForm,
    PageHeader,
  },

  props: {
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const listWalletsPath = wallets.index.path();

    return {
      listWalletsPath,
      t: I18n.scopedTranslator('views.wallets.form'),
    };
  },
};
</script>
