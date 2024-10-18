<template>
  <NoRecordsFound v-if="!wallets.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :columns="walletColumns"
      :rows="wallets"
      :actions="walletActions"
    >
      <template v-slot:default="{ row: wallet }">
        <WalletTableRow :wallet="wallet" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore.js';

import WalletTableRow from '~/components/wallets/WalletTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    WalletTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.wallets_list');

    const walletStore = useWalletStore();

    const { wallets } = storeToRefs(walletStore);

    const handleEditAction = row => walletStore.openFormModal(row.id);
    const handleDisableAction = row => walletStore.disable(row.id);
    const handleReenableAction = row => walletStore.reenable(row.id);
    const isEnabled = row => !row.disabledAt;
    const isDisabled = row => !!row.disabledAt;

    const walletActions = [
      { label: t('edit'), icon: 'pen-to-square', callback: handleEditAction, variant: 'secondary', show: isEnabled },
      { label: t('disable'), icon: 'ban', callback: handleDisableAction, variant: 'danger', show: isEnabled },
      { label: t('reenable'), icon: 'repeat', callback: handleReenableAction, variant: 'success', show: isDisabled },
    ];

    const walletColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('balance_label'), side: 'right', align: 'right' },
    ];

    return {
      wallets,
      walletColumns,
      walletActions,
    };
  },
};
</script>
