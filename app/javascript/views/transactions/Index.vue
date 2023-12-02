<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :href="newTransactionPath"
          :label="t('new')"
          icon="plus"
        />
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

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';

export default {
  components: {
    PageHeader,
    DropdownMenuItem,
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
