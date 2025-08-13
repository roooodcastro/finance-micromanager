<template>
  <div>
    <PageHeader
      :title="t('title')"
      hide-back-button
      show-date-range-picker
    />

    <InProgressReconciliationInfoAlert
      :reconciliation="inProgressReconciliation"
      class="mt-3"
    />

    <TabRowContainer :tabs="firstRowTabs">
      <template v-slot:summary>
        <TransactionsSummary />
      </template>
      <template v-slot:chart>
        <DailyTotalsChart />
      </template>
    </TabRowContainer>

    <div class="row mt-3">
      <div class="col-12 col-lg-6">
        <BCard
          id="dashboard_show_category_summary"
          no-body
        >
          <template v-slot:header>
            <h4 class="card-title m-0 d-flex gap-3 align-items-center">
              {{ t('sub_header_category_summary') }}
              <SeeAllLink :href="categoriesIndexPath" />
            </h4>
          </template>
          <CategorySummariesList />
        </BCard>
      </div>

      <div class="col-12 col-lg-6 mt-3 mt-lg-0">
        <BCard
          id="dashboard_show_recent_transactions"
          no-body
        >
          <template v-slot:header>
            <h4 class="card-title m-0 d-flex gap-3 align-items-center">
              {{ t('sub_header_recent_transactions') }}
              <SeeAllLink :href="transactionsIndexPath" />
            </h4>
          </template>
          <TransactionTypeTabs class="mx-3 mb-3" />

          <TransactionsList card-body />
        </BCard>
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useStatisticsCategorySummaryStore from '~/stores/statistics/CategorySummaryStore.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';
import { onDateRangeChange } from '~/utils/DateRangeWatcher.js';

import {
  categories as categoriesApi,
  transactions as transactionsApi,
} from '~/api/all.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import CategorySummariesList from '~/components/statistics/category_summaries/CategorySummariesList.vue';
import TransactionTypeTabs from '~/components/transactions/TransactionTypeTabs.vue';
import InProgressReconciliationInfoAlert from '~/components/reconciliations/InProgressReconciliationInfoAlert.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import SeeAllLink from '~/components/ui/SeeAllLink.vue';
import DailyTotalsChart from '~/components/transactions/DailyTotalsChart.vue';
import TransactionsSummary from '~/components/dashboard/TransactionsSummary.vue';
import TabRowContainer from '~/components/layout/TabRowContainer.vue';

export default {
  components: {
    BCard,
    CategorySummariesList,
    DailyTotalsChart,
    InProgressReconciliationInfoAlert,
    PageHeader,
    SeeAllLink,
    TabRowContainer,
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
    const t = I18n.scopedTranslator('views.dashboard.show');

    const firstRowTabs = [
      { slot: 'summary', title: t('sub_header_transactions_summary'), colClasses: 'col-md-5 col-lg-4 col-xl-3', fullHeight: true },
      { slot: 'chart', title: t('sub_header_daily_totals_chart'), colClasses: 'col-md-7 col-lg-8 col-xl-9', fullHeight: true },
    ];

    const categoriesIndexPath = categoriesApi.index.path();
    const transactionsIndexPath = transactionsApi.index.path();

    const dateRangeStore = useDateRangeStore();
    const categoryStore = useCategoryStore();
    const paginationStore = usePaginationStore();
    const transactionStore = useTransactionStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();
    const budgetInstanceStore = useBudgetInstanceStore();

    const { categories: categoriesFromStore } = storeToRefs(categoryStore);
    const { categorySummaries: categorySummariesFromStore } = storeToRefs(categorySummaryStore);
    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    categoriesFromStore.value = props.categories;
    categorySummariesFromStore.value = props.categorySummaries;

    budgetInstanceStore.setFetchParams({ startDate, endDate });

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

    onProfileChanged(() => {
      budgetInstanceStore.fetchCollection();
      fetchRecentTransactions();
      fetchCategorySummaries();
    })

    budgetInstanceStore.fetchCollection();
    fetchRecentTransactions();

    onDateRangeChange(() => {
      fetchRecentTransactions();
      fetchCategorySummaries();
      budgetInstanceStore.fetchCollection();
    });

    return {
      t,
      firstRowTabs,
      transactions,
      categoriesIndexPath,
      transactionsIndexPath,
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
