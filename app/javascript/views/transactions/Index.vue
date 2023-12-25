<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />
        <DropdownMenuItem
          :label="t('mass_edit')"
          icon="pen-to-square"
          @click="handleMassEdit"
        />
      </template>
    </PageHeader>

    <div class="d-flex justify-content-between gap-2 mb-3">
      <div class="d-flex gap-2">
        <TransactionsFilter toggle-classes="w-100 btn btn-sm btn-outline-dark" />
        <DateRangeFilter />
      </div>

      <Pagination
        :pagination="pagination"
        compact
        class="d-none d-lg-flex"
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
import DateRangeFilter from '~/components/transactions/DateRangeFilter.vue';

export default {
  components: {
    DateRangeFilter,
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

    const handleNew = () => transactionStore.openFormModal(null);
    const handleMassEdit = transactionStore.enterMassEditMode;
    const handlePageChange = () => transactionStore.fetch();

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      handlePageChange,
      handleNew,
      handleMassEdit,
    };
  },
};
</script>
