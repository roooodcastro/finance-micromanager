<template>
  <PageHeader
    :title="t('title', { date: formatDate(reconciliationFromStore.date) })"
    :back-button-href="reconciliationsPath"
    class="flex-wrap"
  />

  <div class="row">
    <div class="col-12 col-lg-6">
      <ReconciliationSummary :reconciliation="reconciliationFromStore" />

      <ReconciliationWallets class="mt-3" />
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ReconciliationSummary from '~/components/reconciliations/ReconciliationSummary.vue';
import ReconciliationWallets from '~/components/reconciliations/ReconciliationWallets.vue';

export default {
  components: {
    PageHeader,
    ReconciliationSummary,
    ReconciliationWallets,
  },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const reconciliationsPath = reconciliationsApi.index.path();

    const reconciliationWalletStore = useReconciliationWalletStore();
    reconciliationWalletStore.setReconciliationId(props.reconciliation.id);

    // Load reconciliations from props
    const reconciliationStore = useReconciliationStore();
    const { reconciliation: reconciliationFromStore } = storeToRefs(reconciliationStore);
    reconciliationFromStore.value = props.reconciliation;

    return {
      t: I18n.scopedTranslator('views.reconciliations.show'),
      formatDate,
      reconciliationsPath,
      reconciliationFromStore,
    };
  },
};
</script>
