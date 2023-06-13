<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newTransactionPath"
          class="btn btn-outline-secondary"
        >
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <TransactionsList :transactions="transactions" />
  </div>
</template>

<script>
import { transactions } from '~/api';
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    PageHeader,
    TransactionsList,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const newTransactionPath = transactions.new.path();

    return {
      newTransactionPath,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
