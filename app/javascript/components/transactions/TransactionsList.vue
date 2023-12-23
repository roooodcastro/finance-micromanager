<template>
  <div>
    <NoTransactionsPlaceholder v-if="!transactionsFromStore.length" />

    <template v-else>
      <InfiniteScrolling
        :class="{ 'TransactionsList': !cardBody }"
        @scroll="handleInfiniteScrolling"
      >
        <template
          v-for="(transactionsByDate, transactionDate) in groupedTransactions"
          :key="transactionDate"
        >
          <div
            v-if="!compact"
            class="position-sticky top-0 bg-white fw-bold py-2"
            :class="{ 'ps-2 ps-lg-0': !cardBody }"
          >
            {{ formatDate(new Date(transactionDate)) }}
          </div>
          <TransactionListItem
            v-for="transaction in transactionsByDate"
            :key="transaction.id"
            :transaction="transaction"
            :compact="compact"
            :class="{ 'mx-2 mx-lg-0': !cardBody }"
          />
        </template>
      </InfiniteScrolling>

      <Pagination
        :pagination="pagination"
        class="d-none d-lg-flex mt-3"
        :class="{ 'me-2 me-lg-3 mb-2 mb-lg-3': cardBody }"
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
import Pagination from '~/components/rails/Pagination.vue';
import NoTransactionsPlaceholder from '~/components/transactions/NoTransactionsPlaceholder.vue';
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';

export default {
  components: {
    InfiniteScrolling,
    NoTransactionsPlaceholder,
    Pagination,
    TransactionListItem,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      default: () => ({}),
    },
    compact: {
      type: Boolean,
      default: false,
    },
    cardBody: {
      type: Boolean,
      default: false,
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
