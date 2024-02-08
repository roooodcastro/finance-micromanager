<template>
  <div>
    <PageHeader :title="t('new_title')" />

    <TransactionPredictionForm :transaction-prediction="transactionPrediction" />
  </div>
</template>

<script>
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import I18n from '~/utils/I18n.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionPredictionForm from '~/components/transaction_predictions/TransactionPredictionForm.vue';

export default {
  components: {
    TransactionPredictionForm,
    PageHeader,
  },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const indexPath = transactionPredictionsApi.index.path();

    return {
      indexPath,
      t,
    };
  },
};
</script>
