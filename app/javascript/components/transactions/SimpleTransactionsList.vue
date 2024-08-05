<template>
  <NoTransactionsPlaceholder
    v-if="!transactions.length"
    :class="{ 'm-3': cardBody }"
  />

  <template v-else>
    <TransactionListItem
      v-for="transaction in transactions"
      :key="transaction.id"
      :transaction="transaction"
      :compact="true"
    />
  </template>
</template>

<script>

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';

import TransactionListItem from '~/components/transactions/TransactionListItem.vue';
import NoTransactionsPlaceholder from '~/components/transactions/NoTransactionsPlaceholder.vue';

export default {
  components: {
    NoTransactionsPlaceholder,
    TransactionListItem,
  },

  props: {
    cardBody: {
      type: Boolean,
      default: false,
    },
    transactions: {
      type: Array,
      required: true,
    },
  },

  setup() {
    return {
      formatDate,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
