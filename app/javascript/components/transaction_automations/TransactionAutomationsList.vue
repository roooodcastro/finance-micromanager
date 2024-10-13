<template>
  <NoRecordsFound v-if="!transactionAutomations.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :rows="transactionAutomations"
      :headers="tableHeaders"
    >
      <template v-slot:default="{ row }">
        <TransactionAutomationGridItem
          :transaction-automation="row"
        />
      </template>
    </GridTable>

    <div class="list-group">
      <template
        v-for="transactionAutomation in transactionAutomations"
        :key="`${transactionAutomation.id}_${transactionAutomation.updatedAt}`"
      >
        <TransactionAutomationListItem :transaction-automation="transactionAutomation" />
      </template>
    </div>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';

import TransactionAutomationListItem from '~/components/transaction_automations/TransactionAutomationListItem.vue';
import TransactionAutomationGridItem from '~/components/transaction_automations/TransactionAutomationGridItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    TransactionAutomationGridItem,
    TransactionAutomationListItem,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.transaction_automations_list');

    const transactionAutomationStore = useTransactionAutomationStore();

    const { transactionAutomations } = storeToRefs(transactionAutomationStore);

    const tableHeaders = [
      { name: 'name', label: t('name_label'), side: 'left' },
      { name: 'category', label: `${t('category_label')}\n${t('wallet_label')}`, side: 'left' },
      { name: 'schedule', label: `${t('schedule_label')}\n${t('next_run_label')}`, side: 'right' },
      { name: 'amount', label: t('amount_label'), side: 'right', align: 'right' },
    ];

    transactionAutomations.value.forEach((transactionAutomation) => {
      const isDisabled = !!transactionAutomation.disabledAt;
      transactionAutomation.sideStripColor = isDisabled ? 'var(--bs-danger)' : 'var(--bs-primary)';
    });

    return {
      transactionAutomations,
      tableHeaders,
    };
  },
};
</script>
