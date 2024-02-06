<template>
  <NoRecordsFound v-if="!transactionPredictions.length" />

  <div
    v-else
    class="list-group"
  >
    <template
      v-for="transactionPrediction in transactionPredictions"
      :key="`${transactionPrediction.id}_${transactionPrediction.updatedAt}`"
    >
      <TransactionPredictionListItem :transaction-prediction="transactionPrediction" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';

import TransactionPredictionListItem from '~/components/transaction_predictions/TransactionPredictionListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    TransactionPredictionListItem,
  },

  setup() {
    const transactionPredictionStore = useTransactionPredictionStore();

    const { transactionPredictions } = storeToRefs(transactionPredictionStore);

    return {
      transactionPredictions,
    };
  },
};
</script>
