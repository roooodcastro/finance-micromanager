<template>
  <NoRecordsFound v-if="!orderedTransactionAutomations.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :columns="tableColumns"
      :rows="orderedTransactionAutomations"
      :actions="tableActions"
      :side-strip-color="sideStripColorFunction"
      bordered
      rounded
    >
      <template v-slot:default="{ row: transactionAutomation }">
        <TransactionAutomationTableRow :transaction-automation="transactionAutomation" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';
import { editAction, disableAction, reenableAction } from '~/utils/GridTableUtils.js';

import TransactionAutomationTableRow from '~/components/transaction_automations/TransactionAutomationTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    TransactionAutomationTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.transaction_automations_list');

    const transactionAutomationStore = useTransactionAutomationStore();

    const { transactionAutomations } = storeToRefs(transactionAutomationStore);

    const tableActions = [
      editAction(transactionAutomationStore),
      disableAction(transactionAutomationStore),
      reenableAction(transactionAutomationStore),
    ];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: `${t('category_label')}\n${t('wallet_label')}`, side: 'left' },
      { label: `${t('schedule_label')}\n${t('next_run_label')}`, side: 'left' },
      { label: t('amount_label'), side: 'right', align: 'right' },
    ];

    const sideStripColorFunction = (row) => {
      const isDisabled = !!row.disabledAt;
      return isDisabled ? 'var(--bs-danger)' : 'var(--bs-primary)';
    };

    const orderedTransactionAutomations = computed(() => {
      return transactionAutomations.value.toSorted((a, b) => {
        if (!!b.disabledAt !== !!a.disabledAt) {
          return a.disabledAt ? 1 : -1;
        } else {
          return a.transactionName.localeCompare(b.transactionName);
        }
      });
    });

    return {
      orderedTransactionAutomations,
      tableColumns,
      tableActions,
      sideStripColorFunction,
    };
  },
};
</script>
