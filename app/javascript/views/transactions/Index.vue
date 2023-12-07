<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleClick"
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
import I18n from '~/utils/I18n';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';

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
    const transactionStore = useTransactionStore();

    const daysToShowFromQuery = getQueryParams().daysToShow;
    if (daysToShowFromQuery) {
      transactionStore.setFetchParams({ daysToShow: daysToShowFromQuery });
    }

    transactionStore.setFetchParams({
      excludeDebits: !!getQueryParams().excludeDebits,
      excludeCredits: !!getQueryParams().excludeCredits,
    });

    const handleClick = () => transactionStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      handleClick,
    };
  },
};
</script>
