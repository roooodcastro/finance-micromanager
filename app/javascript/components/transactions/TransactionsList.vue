<template>
  <div>
    <TransactionsFilter @change="handleFiltersChange" />

    <NoTransactionsPlaceholder v-if="!transactionsFromStore.length" />
    <template v-else>
      <div class="TransactionsList">
        <template
          v-for="(transactionsByDate, transactionDate) in groupedTransactions"
          :key="transactionDate"
        >
          <div class="position-sticky top-0 bg-white fw-bold py-2 ps-2">
            {{ formatDate(new Date(transactionDate)) }}
          </div>
          <TransactionRow
            v-for="transaction in transactionsByDate"
            :key="transaction.id"
            :transaction="transaction"
          />
        </template>
      </div>

      <Pagination
        :pagination="paginationFromStore"
        @change="handlePageChange"
      />
    </template>
  </div>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useAccountStore from '~/stores/AccountStore.js';

import TransactionRow from '~/components/transactions/TransactionRow.vue';
import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import Pagination from '~/components/rails/Pagination.vue';
import NoTransactionsPlaceholder from "~/components/transactions/NoTransactionsPlaceholder.vue";

export default {
  components: {
    NoTransactionsPlaceholder,
    Pagination,
    TransactionRow,
    TransactionsFilter,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    // Load transactions from props
    const transactionStore = useTransactionStore();
    const {
      transactions: transactionsFromStore,
      pagination: paginationFromStore,
      groupedTransactions
    } = storeToRefs(transactionStore);
    transactionsFromStore.value = toRef(props.transactions).value;
    paginationFromStore.value = toRef(props.pagination).value;

    const handleFiltersChange = () => transactionStore.fetchTransactions();
    const handlePageChange = (page) => transactionStore.changePage(page);

    // Reload transactions if account has changed while this page is open
    const accountStore = useAccountStore();
    watch(
      () => accountStore.currentAccount,
      () => transactionStore.fetchTransactions(),
    );

    return {
      formatDate,
      transactionsFromStore,
      groupedTransactions,
      paginationFromStore,
      handleFiltersChange,
      handlePageChange,
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
