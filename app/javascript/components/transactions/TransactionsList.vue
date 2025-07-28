<template>
  <LoadingOverlay :loading="loading && initialFetchDone">
    <MassEditForm />
    <NoTransactionsPlaceholder
      v-if="initialFetchDone && !transactions.length"
      :class="{ 'm-3': cardBody }"
    />

    <template v-else>
      <MassEditControls />

      <InfiniteScrolling @scroll="handleInfiniteScrolling">
        <template v-if="!initialFetchDone">
          <TransactionListItemPlaceholder
            v-for="n in 5"
            :key="n"
          />
        </template>
        <template
          v-for="(transactionsByDate, transactionDate) in groupedTransactions"
          v-else
          :key="transactionDate"
        >
          <div
            v-if="!compact"
            class="position-sticky top-0 bg-body-tertiary fw-bold py-2 ps-2"
            :class="{ 'ps-2 ps-lg-0': !cardBody }"
          >
            {{ formatDate(new Date(transactionDate)) }}
          </div>
          <TransactionListItem
            v-for="transaction in transactionsByDate"
            :key="transaction.id"
            :transaction="transaction"
            :compact="compact"
            :mass-edit-mode="massEditMode"
            :mass-edit-selected="massEditTransactionIds[transaction.id]"
            @mass-edit-toggle="handleMassEditToggle"
          />
        </template>
      </InfiniteScrolling>

      <Pagination
        v-if="!loading"
        class="d-none d-lg-flex mt-3"
        :class="{ 'me-2 me-lg-3 mb-2 mb-lg-3': cardBody }"
        @change="handlePageChange"
      />
    </template>
  </LoadingOverlay>
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';

import TransactionListItem from '~/components/transactions/TransactionListItem.vue';
import Pagination from '~/components/rails/Pagination.vue';
import NoTransactionsPlaceholder from '~/components/transactions/NoTransactionsPlaceholder.vue';
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';
import MassEditForm from '~/components/transactions/MassEditForm.vue';
import TransactionListItemPlaceholder from '~/components/transactions/TransactionListItemPlaceholder.vue';
import MassEditControls from '~/components/transactions/MassEditControls.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    InfiniteScrolling,
    LoadingOverlay,
    MassEditControls,
    MassEditForm,
    NoTransactionsPlaceholder,
    Pagination,
    TransactionListItem,
    TransactionListItemPlaceholder,
  },

  props: {
    compact: {
      type: Boolean,
      default: false,
    },
    cardBody: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const paginationStore = usePaginationStore();
    const transactionStore = useTransactionStore();
    const {
      loading,
      transactions,
      initialFetchDone,
      groupedTransactions,
      massEditMode,
      massEditTransactionIds,
    } = storeToRefs(transactionStore);

    const handlePageChange = () => transactionStore.fetchCollection();

    const loadingNextPage = ref(false);

    const handleInfiniteScrolling = () => {
      if (isMediaBreakpointDown('md') && !loadingNextPage.value) {
        loadingNextPage.value = true;

        if (paginationStore.incrementPage()) {
          transactionStore.fetchCollection({ keepTransactions: true }).then(() => {
            loadingNextPage.value = false;
          });
        }
      }
    };

    const handleMassEditToggle = transactionStore.toggleMassEditTransactionId;

    return {
      formatDate,
      loading,
      initialFetchDone,
      transactions,
      groupedTransactions,
      massEditMode,
      massEditTransactionIds,
      handlePageChange,
      handleInfiniteScrolling,
      handleMassEditToggle,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
