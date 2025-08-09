<template>
  <LoadingOverlay :loading="loading">
    <NoTransactionsPlaceholder
      v-if="initialFetchDone && !transactionsForList.length"
      :class="{ 'm-3': cardBody }"
    />

    <template v-else>
      <MassEditControls
        v-if="massEditMode"
        :card-body="cardBody"
      />

      <InfiniteScrolling @scroll="handleInfiniteScrolling">
        <template
          v-for="(transactionsByDate, transactionDate, index) in groupedTransactions"
          :key="transactionDate"
        >
          <GridTable
            v-if="!compact && index === 0"
            :actions="[{}]"
            :columns="transactionColumns"
            :rows="[]"
            :sorting="sortParams"
            force-mobile-when-smaller-than="lg"
            actions-grid-size="6rem"
            rounded
            @sort="handleSorting"
          />

          <div
            v-if="!compact"
            class="top-0 fw-bold border rounded m-2"
            :class="{ 'ps-2 ps-lg-0': !cardBody }"
          >
            <div class="px-2 py-2 fw-bold border-bottom bg-body-secondary">
              {{ formatDate(new Date(transactionDate)) }}
            </div>
            <GridTable
              :actions="transactionActions"
              :columns="transactionColumns"
              :rows="transactionsByDate"
              :side-strip-color="sideStripColorFunction"
              :row-click-handler="massEditMode ? handleMassEditSelect : null"
              force-mobile-when-smaller-than="lg"
              actions-grid-size="6rem"
              no-header
              hoverable
              rounded
            >
              <template v-slot:default="{ row: transaction, forcedMobile }">
                <TransactionTableRow
                  :transaction="transaction"
                  :forced-mobile="forcedMobile"
                />
              </template>
            </GridTable>
          </div>

          <div
            v-else
            class="border-bottom"
          >
            <GridTable
              :actions="transactionActions"
              :columns="transactionColumns"
              :rows="transactionsByDate"
              :side-strip-color="sideStripColorFunction"
              :row-click-handler="massEditMode ? handleMassEditSelect : null"
              :no-header="index > 0"
              :sorting="sortParams"
              force-mobile-when-smaller-than="lg"
              hoverable
              @sort="handleSorting"
            >
              <template v-slot:default="{ row: transaction, forcedMobile }">
                <TransactionTableRow
                  :transaction="transaction"
                  :forced-mobile="forcedMobile"
                />
              </template>
            </GridTable>
          </div>
        </template>
      </InfiniteScrolling>

      <Pagination
        v-if="!loading"
        class="d-none d-lg-flex mt-3"
        :class="{ 'me-2 me-lg-3 mb-2 mb-lg-3': cardBody }"
        @change="handlePageChange"
      />
    </template>

    <MassEditForm />
  </LoadingOverlay>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';
import { setQueryParam } from '~/utils/QueryStringUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';

import GridTable from '~/components/ui/GridTable.vue';
import TransactionTableRow from '~/components/transactions/TransactionTableRow.vue';
import Pagination from '~/components/rails/Pagination.vue';
import NoTransactionsPlaceholder from '~/components/transactions/NoTransactionsPlaceholder.vue';
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';
import MassEditForm from '~/components/transactions/MassEditForm.vue';
import MassEditControls from '~/components/transactions/MassEditControls.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    GridTable,
    InfiniteScrolling,
    LoadingOverlay,
    MassEditControls,
    MassEditForm,
    NoTransactionsPlaceholder,
    Pagination,
    TransactionTableRow,
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
    transactions: {
      type: Array,
      default: null,
    },
    sortable: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.components.transactions.transactions_list');

    const paginationStore = usePaginationStore();
    const transactionStore = useTransactionStore();

    const {
      loading,
      transactions: transactionsFromStore,
      initialFetchDone,
      groupedTransactions,
      massEditMode,
      massEditTransactionIds,
      sortParams,
    } = storeToRefs(transactionStore);

    const transactionActions = computed(() => {
      if (massEditMode.value) {
        return [];
      } else {
        return [
          {
            icon: 'pen-to-square',
            callback: row => transactionStore.openFormModal(row.id),
            variant: 'secondary',
          },
          {
            icon: ['far', 'trash-can'],
            callback: row => transactionStore.destroy(row.id),
            variant: 'danger',
          },
        ];
      }
    });

    const transactionColumns = [
      { label: t('name_label'), side: 'left', gridSize: '6fr' },
      { label: t('category_label'), side: 'left', gridSize: 'minmax(10rem, 3fr)' },
      { label: t('date_label'), side: 'right', align: 'left', gridSize: 'minmax(8rem, 2fr)', sortColumn: props.sortable ? 'transaction_date' : null },
      { label: t('wallet_label'), side: 'right', align: 'left', gridSize: 'minmax(10rem, 3fr)' },
      { label: t('amount_label'), side: 'right', align: 'right', gridSize: 'minmax(8rem, 2fr)' },
    ];

    const handlePageChange = () => transactionStore.fetchCollection();

    const transactionsForList = computed(() => props.transactions ? props.transactions : transactionsFromStore.value);

    const sideStripColorFunction = row => row.category.color;

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

    const handleMassEditSelect = (transaction) => {
      transactionStore.toggleMassEditTransactionId(transaction.id);
    };

    const handleSorting = (sortColumn) => {
      const newSortDirection = sortParams.value.sortDirection?.toLowerCase() === 'asc' ? 'desc' : 'asc';
      const sortDirection = sortParams.value.sortColumn === sortColumn ? newSortDirection : 'asc';
      setQueryParam('sort_direction', sortDirection);

      transactionStore.setFetchParams({ sortDirection });
      transactionStore.fetchCollection();
    };

    return {
      t,
      formatDate,
      loading,
      initialFetchDone,
      transactionsForList,
      groupedTransactions,
      massEditMode,
      massEditTransactionIds,
      transactionActions,
      transactionColumns,
      sortParams,
      handlePageChange,
      handleInfiniteScrolling,
      handleSorting,
      sideStripColorFunction,
      handleMassEditSelect,
    };
  },
};
</script>
