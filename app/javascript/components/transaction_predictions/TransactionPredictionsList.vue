<template>
  <NoRecordsFound v-if="!transactionPredictions.length" />

  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :actions="tableActions"
      :columns="tableColumns"
      :rows="transactionPredictions"
    >
      <template v-slot:default="{ row: transactionPrediction }">
        <TransactionPredictionTableRow :transaction-prediction="transactionPrediction" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import { disableAction, reenableAction } from '~/utils/GridTableUtils.js';

import TransactionPredictionTableRow from '~/components/transaction_predictions/TransactionPredictionTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    TransactionPredictionTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.transaction_predictions_list');

    const transactionPredictionStore = useTransactionPredictionStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const { transactionPredictions } = storeToRefs(transactionPredictionStore);
    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const tableActions = [
      {
        label: t('edit_action'),
        href: row => transactionPredictionsApi.edit.path({ id: row.id }),
        variant: 'secondary',
        icon: 'pen-to-square',
        show: row => !row.disabledAt,
      },
      disableAction(transactionPredictionStore),
      reenableAction(transactionPredictionStore),
    ];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('conditions_label'), side: 'left' },
      { label: t('actions_label'), side: 'left' },
    ];

    return {
      transactionPredictions,
      tableActions,
      tableColumns,
    };
  },
};
</script>
