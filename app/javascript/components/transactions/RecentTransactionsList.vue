<template>
  <div>
    <NoTransactionsPlaceholder
      v-if="!transactions.length"
      class="mb-3"
    />

    <div
      v-else
      class="list-group overflow-hidden px-0 rounded-0"
    >
      <TransactionListItem
        v-for="transaction in transactions"
        :key="transaction.id"
        :transaction="transaction"
        compact
      />

      <a
        v-if="showViewMoreLink"
        :href="transactionsPath"
        class="list-group-item list-group-item-action rounded-0 border-top-0 border-bottom-0 text-center py-3"
        v-html="t('view_more')"
      />
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import NoTransactionsPlaceholder from '~/components/transactions/NoTransactionsPlaceholder.vue';
import TransactionListItem from '~/components/transactions/TransactionListItem.vue';
import { transactions as transactionsApi } from '~/api/all.js';

export default {
  components: {
    NoTransactionsPlaceholder,
    TransactionListItem,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
    showViewMoreLink:{
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const transactionsPath = transactionsApi.index.path();

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      transactionsPath,
    };
  },
};
</script>
