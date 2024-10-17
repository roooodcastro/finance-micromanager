<template>
  <NoRecordsFound v-if="!transactionAutomations.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :columns="tableColumns"
      :rows="transactionAutomations"
      :actions="tableActions"
      :side-strip-color="sideStripColorFunction"
    >
      <template v-slot:default="{ row: transactionAutomation }">
        <TransactionAutomationTableRow :transaction-automation="transactionAutomation" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';

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

    const handleEditAction = row => transactionAutomationStore.openFormModal(row.id);
    const handleDisableAction = row => transactionAutomationStore.disable(row.id);
    const handleReenableAction = row => transactionAutomationStore.reenable(row.id);
    const isEnabled = row => !row.disabledAt;
    const isDisabled = row => !!row.disabledAt;

    const tableActions = [
      { label: t('edit'), icon: 'pen-to-square', callback: handleEditAction, variant: 'secondary', show: isEnabled },
      { label: t('disable'), icon: 'ban', callback: handleDisableAction, variant: 'danger', show: isEnabled },
      { label: t('reenable'), icon: 'repeat', callback: handleReenableAction, variant: 'success', show: isDisabled },
    ];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: `${t('category_label')}\n${t('wallet_label')}`, side: 'left' },
      { label: `${t('schedule_label')}\n${t('next_run_label')}`, side: 'right' },
      { label: t('amount_label'), side: 'right', align: 'right' },
    ];

    const sideStripColorFunction = (row) => {
      const isDisabled = !!row.disabledAt;
      return isDisabled ? 'var(--bs-danger)' : 'var(--bs-primary)';
    }

    return {
      transactionAutomations,
      tableColumns,
      tableActions,
      sideStripColorFunction,
    };
  },
};
</script>
