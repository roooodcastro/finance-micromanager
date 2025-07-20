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
      bordered
      rounded
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
import { editAction, disableAction, reenableAction } from '~/utils/GridTableUtils.js';

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

    const walletActions = [
      editAction(walletStore),
      disableAction(walletStore),
      reenableAction(walletStore),
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
