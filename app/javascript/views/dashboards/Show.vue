<template>
  <div>
    <PageHeader :title="t('title')" />

    <InProgressReconciliationInfoAlert :reconciliation="inProgressReconciliation" />

    <DateRangeSelector
      class="mb-3 mx-1 mx-lg-0"
      @change="handleDateRangeChange"
    />

    <div class="row">
      <div class="col-12 col-lg-6">
        <TransactionsSummary />
      </div>
      <div class="col-12 col-lg-6 mt-3 mt-lg-0">
        <DailyTotalsChart />
      </div>
    </div>

    <div class="row mt-3">
      <div class="col-12 col-lg-6">
        <BCard
          id="dashboard_show_category_summary"
          :title="t('sub_header_category_summary')"
          no-body
        >
          <CategorySummariesList />
        </BCard>
      </div>

      <div class="col-12 col-lg-6 mt-3 mt-lg-0">
        <BCard
          id="dashboard_show_recent_transactions"
          :title="t('sub_header_recent_transactions')"
          no-body
        >
          <TransactionTypeTabs class="mx-3 mb-3" />

          <TransactionsList
            compact
            card-body
          />
        </BCard>
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
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import CategorySummariesList from '~/components/statistics/category_summaries/CategorySummariesList.vue';
import TransactionTypeTabs from '~/components/transactions/TransactionTypeTabs.vue';
import InProgressReconciliationInfoAlert from '~/components/reconciliations/InProgressReconciliationInfoAlert.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import DailyTotalsChart from '~/components/transactions/DailyTotalsChart.vue';
import TransactionsSummary from '~/components/dashboard/TransactionsSummary.vue';

export default {
  components: {
    BCard,
    CategorySummariesList,
    DailyTotalsChart,
    DateRangeSelector,
    InProgressReconciliationInfoAlert,
    PageHeader,
    TransactionsList,
    TransactionsSummary,
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
      transactionStore.setFetchParams({ daysToShow: 0, includeStatistics: true });
      paginationStore.setPaginationOptions({
        startDate: startDate.value,
        endDate: endDate.value,
      });

      transactionStore.fetchCollection();
    }

    const fetchCategorySummaries = () => {
      categorySummaryStore.fetchCollection({
        startDate: startDate.value,
        endDate: endDate.value,
      });
    }

    watch(transactions, fetchCategorySummaries);
    fetchRecentTransactions();

    const handleDateRangeChange = () => {
      fetchRecentTransactions();
    };

    return {
      t: I18n.scopedTranslator('views.dashboard.show'),
      transactions,
      handleDateRangeChange,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .card {
    border-radius: 0 !important;
  }
}
</style>
