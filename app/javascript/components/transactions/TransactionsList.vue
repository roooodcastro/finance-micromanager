<template>
  <div>
    <div class="d-flex justify-content-between">
      <TransactionsFilter @change="handleFiltersChange" />

      <Pagination
        :pagination="pagination"
        compact
        class="d-none d-lg-flex mb-3"
        @change="handlePageChange"
      />
    </div>

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
        :pagination="pagination"
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
import usePaginationStore from '~/stores/PaginationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';

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
    const paginationStore = usePaginationStore();
    // Load transactions from props
    const transactionStore = useTransactionStore();
    const {
      transactions: transactionsFromStore,
      groupedTransactions
    } = storeToRefs(transactionStore);
    transactionsFromStore.value = toRef(props.transactions).value;

    const handleFiltersChange = () => transactionStore.fetch();
    const handlePageChange = () => transactionStore.fetch();

    // Reload transactions if profile has changed while this page is open
    const profileStore = useProfileStore();
    watch(
      () => profileStore.currentProfile,
      () => transactionStore.fetch(),
    );

    const loadingNextPage = ref(false);

    const handleInfiniteScrolling = () => {
      if (isMediaBreakpointDown('md') && !loadingNextPage.value) {
        loadingNextPage.value = true;

        if (paginationStore.incrementPage()) {
          transactionStore.fetch({ keepTransactions: true }).then(() => {
            loadingNextPage.value = false;
          });
        }
      }
    };

    return {
      formatDate,
      transactionsFromStore,
      groupedTransactions,
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
