<template>
  <div>
    <PageHeader :title="t('title')" />

    <DateRangeSelector
      class="mb-3"
      @change="handleDateRangeChange"
    />

    <div class="row">
      <div class="col-12 col-lg-6">
        <div class="card overflow-hidden">
          <div class="card-header">
            <h5 class="m-0">{{ t('category_summary') }}</h5>
          </div>
          <CategorySummariesList />
        </div>
      </div>

      <div class="col-12 col-lg-6 mt-3 mt-lg-0">
        <div class="card overflow-hidden">
          <div class="card-header">
            <h5 class="m-0">{{ t('recent_transactions') }}</h5>
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
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n';
import useTransactionStore from '~/stores/TransactionStore';
import useDateRangeStore from '~/stores/DateRangeStore';
import useCategoryStore from '~/stores/CategoryStore.js';
import useStatisticsCategorySummaryStore from '~/stores/statistics/CategorySummaryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import CategorySummariesList from '~/components/statistics/category_summaries/CategorySummariesList.vue';

export default {
  components: {
    CategorySummariesList,
    DateRangeSelector,
    PageHeader,
    RecentTransactionsList,
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
  },

  setup(props) {
    const dateRangeStore = useDateRangeStore();
    const categoryStore = useCategoryStore();
    const transactionStore = useTransactionStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();


    const { categories: categoriesFromStore } = storeToRefs(categoryStore);
    const { categorySummaries: categorySummariesFromStore } = storeToRefs(categorySummaryStore);
    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    transactionStore.fetchTransactions({ items: 10 });

    categoriesFromStore.value = props.categories;
    categorySummariesFromStore.value = props.categorySummaries;

    const handleDateRangeChange = () => {
      transactionStore.fetchTransactions({
        startDate: startDate.value,
        endDate: endDate.value,
        items: 10,
        daysToShow: 0,
      });
      categorySummaryStore.fetch({
        startDate: startDate.value,
        endDate: endDate.value,
      });
    };

    return {
      t: I18n.scopedTranslator('views.dashboard'),
      transactions,
      handleDateRangeChange,
    };
  },
};
</script>
