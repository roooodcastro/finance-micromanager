<template>
  <div class="list-group">
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

export default {
  components: {
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
