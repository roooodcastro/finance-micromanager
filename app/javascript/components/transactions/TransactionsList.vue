<template>
  <div>
    <Pagination
      :pagination="paginationFromStore"
      class="d-none d-lg-flex mb-3"
      @change="handlePageChange"
    />

    <TransactionsFilter @change="handleFiltersChange" />

    <NoTransactionsPlaceholder v-if="!transactionsFromStore.length" />

    <template v-else>
      <InfiniteScrolling
        class="TransactionsList"
        @scroll="handleInfiniteScrolling"
      >
        <template
          v-for="(transactionsByDate, transactionDate) in groupedTransactions"
          :key="transactionDate"
        >
          <div class="position-sticky top-0 bg-white fw-bold py-2 ps-2 ps-lg-0">
            {{ formatDate(new Date(transactionDate)) }}
          </div>
          <TransactionListItem
            v-for="transaction in transactionsByDate"
            :key="transaction.id"
            :transaction="transaction"
            class="mx-2 mx-lg-0"
          />
        </template>
      </InfiniteScrolling>

      <Pagination
        :pagination="paginationFromStore"
        class="d-none d-lg-flex mt-3"
        @change="handlePageChange"
      />
    </template>
  </div>
</template>

<script>
import { watch, toRef, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useWalletStore from '~/stores/WalletStore.js';

import TransactionListItem from '~/components/transactions/TransactionListItem.vue';
import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import Pagination from '~/components/rails/Pagination.vue';
import NoTransactionsPlaceholder from "~/components/transactions/NoTransactionsPlaceholder.vue";
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';

export default {
  components: {
    InfiniteScrolling,
    NoTransactionsPlaceholder,
    Pagination,
    TransactionListItem,
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

    // Reload transactions if wallet has changed while this page is open
    const walletStore = useWalletStore();
    watch(
      () => walletStore.currentWallet,
      () => transactionStore.fetchTransactions(),
    );

    const loadingNextPage = ref(false);

    const handleInfiniteScrolling = () => {
      if (isMediaBreakpointDown('md') && !loadingNextPage.value) {
        loadingNextPage.value = true;

        transactionStore.fetchNextPage().then(() => {
          loadingNextPage.value = false;
        });
      }
    };

    return {
      formatDate,
      transactionsFromStore,
      groupedTransactions,
      paginationFromStore,
      handleFiltersChange,
      handlePageChange,
      handleInfiniteScrolling,
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
