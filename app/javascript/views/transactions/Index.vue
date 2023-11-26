<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newTransactionPath"
          class="btn btn-sm btn-outline-secondary mt-2 mt-lg-0"
        >
          <FontAwesomeIcon
            icon="plus"
            size="lg"
            class="me-2"
          />
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <TransactionsList
      :transactions="transactions"
      :pagination="pagination"
    />
  </div>
</template>

<script>
import { transactions } from '~/api';
import I18n from '~/utils/I18n';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    FontAwesomeIcon,
    PageHeader,
    TransactionsList,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
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
