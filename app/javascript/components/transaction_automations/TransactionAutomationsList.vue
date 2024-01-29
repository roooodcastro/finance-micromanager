<template>
  <NoRecordsFound v-if="!transactionAutomations.length" />
  <div
    v-else
    class="list-group"
  >
    <template
      v-for="transactionAutomation in transactionAutomations"
      :key="`${transactionAutomation.id}_${transactionAutomation.updatedAt}`"
    >
      <TransactionAutomationListItem :transaction-automation="transactionAutomation" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';

import TransactionAutomationListItem from '~/components/transaction_automations/TransactionAutomationListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    TransactionAutomationListItem,
  },

  setup() {
    const transactionAutomationStore = useTransactionAutomationStore();

    const { transactionAutomations } = storeToRefs(transactionAutomationStore);

    return {
      transactionAutomations,
    };
  },
};
</script>
