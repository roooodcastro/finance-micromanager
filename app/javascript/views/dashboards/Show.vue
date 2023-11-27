<template>
  <div>
    <PageHeader :title="t('title')" />

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

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import { storeToRefs } from 'pinia';

export default {
  components: {
    PageHeader,
    RecentTransactionsList,
  },

  setup() {
    const transactionStore = useTransactionStore();
    const { transactions } = storeToRefs(transactionStore);
    transactionStore.fetchTransactions({ items: 10 });

    return {
      t: I18n.scopedTranslator('views.dashboard'),
      transactions,
    };
  },
};
</script>
