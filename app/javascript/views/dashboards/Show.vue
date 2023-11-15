<template>
  <div>
    <PageHeader :title="t('title')" />

    <TransactionsList
      :pagination="{}"
      :transactions="[]"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n';
import useTransactionStore from '~/stores/TransactionStore';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    PageHeader,
    TransactionsList,
  },

  setup() {
    useTransactionStore().fetchTransactions();

    return {
      t: I18n.scopedTranslator('views.dashboard'),
    };
  },
};
</script>
