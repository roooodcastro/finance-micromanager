<template>
  <div class="list-group">
    <template
      v-for="reconciliation in reconciliations"
      :key="`${reconciliation.id}_${reconciliation.updatedAt}`"
    >
      <ReconciliationListItem :reconciliation="reconciliation" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useReconciliationStore from '~/stores/ReconciliationStore.js';

import ReconciliationListItem from '~/components/reconciliations/ReconciliationListItem.vue';

export default {
  components: {
    ReconciliationListItem,
  },

  setup() {
    const reconciliationStore = useReconciliationStore();

    const { reconciliations } = storeToRefs(reconciliationStore);

    return {
      reconciliations,
    };
  },
};
</script>
