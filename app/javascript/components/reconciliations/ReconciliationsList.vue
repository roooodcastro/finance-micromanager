<template>
  <NoRecordsFound v-if="!reconciliations.length" />

  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :actions="reconciliationActions"
      :columns="reconciliationColumns"
      :rows="reconciliations"
      :side-strip-color="sideStripColorFunction"
    >
      <template v-slot:default="{ row: reconciliation }">
        <ReconciliationTableRow :reconciliation="reconciliation" />
      </template>
    </GridTable>
  </bcard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { COLORS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import ReconciliationTableRow from '~/components/reconciliations/ReconciliationTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    ReconciliationTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.reconciliations_list');

    const reconciliationStore = useReconciliationStore();
    const modalStore = useModalStore();

    const { reconciliations } = storeToRefs(reconciliationStore);

    const handleCancel = (row) => {
      modalStore
        .showConfirmationDialog({ message: I18n.t('views.reconciliations.index.confirm_cancel_message') })
        .then(() => reconciliationStore.cancel(row.id))
        .catch(() => {});
    };

    const reconciliationActions = [
      {
        label: t('cancel_action'),
        icon: ['far', 'trash-can'],
        callback: handleCancel,
        variant: 'danger',
        show: row => row.status === 'in_progress'
      }
    ];

    const reconciliationColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('status_label'), side: 'left' },
      { label: t('balance_diff_label'), side: 'right', align: 'right' },
    ];

    const sideStripColorFunction = (row) => COLORS_FOR_RECONCILIATION_STATUSES[row.status];

    return {
      reconciliations,
      reconciliationActions,
      reconciliationColumns,
      sideStripColorFunction,
    };
  },
};
</script>
