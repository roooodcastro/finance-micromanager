<template>
  <div>
    <NoTransactionsPlaceholder
      v-if="!transactions.length"
      class="mb-3"
    />

    <div
      v-else
      class="list-group overflow-hidden px-0"
    >
      <TransactionListItem
        v-for="transaction in transactions"
        :key="transaction.id"
        :transaction="transaction"
        :show-delete-button="false"
        show-date
      />
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import NoTransactionsPlaceholder from "~/components/transactions/NoTransactionsPlaceholder.vue";
import TransactionListItem from '~/components/transactions/TransactionListItem.vue';

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
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .TransactionsList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
