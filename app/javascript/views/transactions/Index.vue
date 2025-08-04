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
      <TransactionsFilter
        show-date-range
        show-search
        class="mx-2 mx-lg-0 mt-3 mt-lg-0"
      />

      <Pagination
        compact
        class="d-none d-lg-flex align-self-end"
        @change="handlePageChange"
      />
    </div>

    <BCard no-body>
      <TransactionsList card-body />
    </BCard>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import Pagination from '~/components/rails/Pagination.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
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

  setup(props) {
    const transactionStore = useTransactionStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    transactionStore.loadCollectionFromProps(props.transactions);

    const daysToShowFromQuery = getQueryParams().daysToShow;
    if (daysToShowFromQuery) {
      transactionStore.setFetchParams({ daysToShow: daysToShowFromQuery });
    }

    const paginationStore = usePaginationStore();
    const { pagination: paginationFromStore } = storeToRefs(paginationStore);
    paginationFromStore.value = props.pagination;

    transactionStore.setFetchParams({
      excludeDebits: !!getQueryParams().excludeDebits,
      excludeCredits: !!getQueryParams().excludeCredits,
      startDate: null,
      endDate: null,
    });

    onProfileChanged(() => {
      transactionStore.fetchCollection();
      categoryStore.fetchCollection();
      walletStore.fetchCollection();
    });

    const handleNew = () => transactionStore.openFormModal(null);
    const handleMassEdit = transactionStore.enterMassEditMode;
    const handlePageChange = () => transactionStore.fetchCollection();

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      paginationFromStore,
      handlePageChange,
      handleNew,
      handleMassEdit,
    };
  },
};
</script>
