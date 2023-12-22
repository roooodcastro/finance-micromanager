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

    <div class="d-flex justify-content-between">
      <TransactionsFilter @change="handleFiltersChange" />

      <Pagination
        :pagination="pagination"
        compact
        class="d-none d-lg-flex mb-3"
        @change="handlePageChange"
      />
    </div>

    <TransactionsList
      :transactions="transactions"
      :pagination="pagination"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import Pagination from '~/components/rails/Pagination.vue';

export default {
  components: {
    DropdownMenuItem,
    PageHeader,
    Pagination,
    TransactionsFilter,
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
    const handleFiltersChange = () => transactionStore.fetch();
    const handlePageChange = () => transactionStore.fetch();

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      handleFiltersChange,
      handlePageChange,
      handleClick,
    };
  },
};
</script>
