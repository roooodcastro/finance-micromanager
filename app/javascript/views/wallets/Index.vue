<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          href="#"
          :label="t('new')"
          icon="plus"
          data-bs-toggle="modal"
          :data-bs-target="`#${WALLET_FORM_MODAL_ID}`"
          @click="handleNew"
        />
      </template>
    </PageHeader>

    <WalletForm />
    <WalletsList />
  </div>
</template>

<script>
import I18n from '~/utils/I18n';
import useWalletStore from '~/stores/WalletStore.js';
import { WALLET_FORM_MODAL_ID } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import WalletsList from '~/components/wallets/WalletsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import WalletForm from '~/components/wallets/WalletForm.vue';

export default {
  components: {
    WalletForm,
    WalletsList,
    PageHeader,
    DropdownMenuItem,
  },

  props: {
    wallets: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const walletStore = useWalletStore();
    walletStore.loadFromProps(props.wallets);

    const handleNew = () => walletStore.setIdForFormModal(crypto.randomUUID());

    return {
      t: I18n.scopedTranslator('views.wallets.index'),
      handleNew,
      WALLET_FORM_MODAL_ID,
    };
  },
};
</script>
