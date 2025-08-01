<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />

        <hr class="my-2">

        <DropdownMenuCheckItem
          :label="t('show_disabled')"
          :checked="showDisabled"
          @click="handleShowDisabled"
        />
      </template>
    </PageHeader>

    <WalletForm />
    <WalletsList />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { ICON_WALLETS } from '~/utils/Constants.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import WalletsList from '~/components/wallets/WalletsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import WalletForm from '~/components/wallets/WalletForm.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';

export default {
  components: {
    DropdownMenuCheckItem,
    DropdownMenuItem,
    WalletForm,
    WalletsList,
    PageHeader,
  },

  props: {
    wallets: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const walletStore = useWalletStore();
    walletStore.loadCollectionFromProps(props.wallets);

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.wallets.floating_button_label'),
      icon: ICON_WALLETS,
      callback: () => walletStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    onProfileChanged(() => walletStore.fetchCollection());

    const { showDisabled }  = storeToRefs(walletStore);

    const handleNew = () => walletStore.openFormModal(null);

    const handleShowDisabled = () => {
      walletStore.setFetchParams({ showDisabled: !showDisabled.value });
      walletStore.fetchCollection();
    };

    return {
      t: I18n.scopedTranslator('views.wallets.index'),
      showDisabled,
      handleNew,
      handleShowDisabled,
    };
  },
};
</script>
