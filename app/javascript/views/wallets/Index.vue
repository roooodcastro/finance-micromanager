<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
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

    const handleNew = () => walletStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.wallets.index'),
      handleNew,
    };
  },
};
</script>
