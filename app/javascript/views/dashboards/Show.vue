<template>
  <div>
    <PageHeader :title="t('title')" />

    <InProgressReconciliationInfoAlert :reconciliation="inProgressReconciliation" />

    <DateRangeSelector
      class="mb-3"
      @change="handleDateRangeChange"
    />

    <div class="row">
      <div class="col-12 col-lg-6">
        <div class="card overflow-hidden">
          <div class="card-header">
            <h5 class="m-0">
              {{ t('category_summary') }}
            </h5>
          </div>
          <CategorySummariesList />
        </div>
      </div>

      <div class="col-12 col-lg-6 mt-3 mt-lg-0">
        <div class="card overflow-hidden">
          <div class="card-header">
            <h5 class="m-0 mb-2">
              {{ t('recent_transactions') }}
            </h5>

            <TransactionTypeTabs />
          </div>
          <RecentTransactionsList
            :transactions="transactions"
            show-view-more-link
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useStatisticsCategorySummaryStore from '~/stores/statistics/CategorySummaryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import CategorySummariesList from '~/components/statistics/category_summaries/CategorySummariesList.vue';
import TransactionTypeTabs from '~/components/transactions/TransactionTypeTabs.vue';
import InProgressReconciliationInfoAlert from '~/components/reconciliations/InProgressReconciliationInfoAlert.vue';

export default {
  components: {
    CategorySummariesList,
    DateRangeSelector,
    InProgressReconciliationInfoAlert,
    PageHeader,
    RecentTransactionsList,
    TransactionTypeTabs,
  },

  props: {
    categorySummaries: {
      type: Array,
      required: true,
    },
    categories: {
      type: Array,
      required:true,
    },
    inProgressReconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const dateRangeStore = useDateRangeStore();
    const categoryStore = useCategoryStore();
    const paginationStore = usePaginationStore();
    const transactionStore = useTransactionStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();

    const { categories: categoriesFromStore } = storeToRefs(categoryStore);
    const { categorySummaries: categorySummariesFromStore } = storeToRefs(categorySummaryStore);
    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    categoriesFromStore.value = props.categories;
    categorySummariesFromStore.value = props.categorySummaries;

    const fetchRecentTransactions = () => {
      transactionStore.setFetchParams({ daysToShow: 0 });
      paginationStore.setPaginationOptions({
        startDate: startDate.value,
        endDate: endDate.value,
        items: 10,
      })

      transactionStore.fetch();
    }

    const fetchCategorySummaries = () => {
      categorySummaryStore.fetch({
        startDate: startDate.value,
        endDate: endDate.value,
      });
    }

    watch(() => transactions.value, fetchCategorySummaries);
    fetchRecentTransactions();

    const handleDateRangeChange = () => {
      fetchRecentTransactions();
      fetchCategorySummaries();
    };

    return {
      t: I18n.scopedTranslator('views.dashboard.show'),
      transactions,
      handleDateRangeChange,
    };
  },
};
</script>
