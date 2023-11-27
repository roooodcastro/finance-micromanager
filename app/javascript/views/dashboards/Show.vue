<template>
  <div>
    <PageHeader :title="t('title')" />

    <DateRangeSelector
      class="mb-3"
      @change="handleDateRangeChange"
    />

    <div class="card">
      <div class="card-header">
        <h5 class="m-0">{{ t('recent_transactions') }}</h5>
      </div>
      <RecentTransactionsList
        :transactions="transactions"
        show-view-more-link
      />
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n';
import useTransactionStore from '~/stores/TransactionStore';
import useDateRangeStore from '~/stores/DateRangeStore';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import { storeToRefs } from 'pinia';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';

export default {
  components: {
    DateRangeSelector,
    PageHeader,
    RecentTransactionsList,
  },

  setup() {
    const dateRangeStore = useDateRangeStore();
    const transactionStore = useTransactionStore();

    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    transactionStore.fetchTransactions({ items: 10 });

    const handleDateRangeChange = () => {
      transactionStore.fetchTransactions({
        startDate: startDate.value,
        endDate: endDate.value,
        items: 10,
        daysToShow: 0
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
