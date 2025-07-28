<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  <ImportSummary
    :import-object="importObject"
    :transaction-count="pagination.count"
  />

  <BCard
    :title="t('imported_transactions_header', { count: pagination.count })"
    class="mt-3"
    no-body
  >
    <TransactionsList
      compact
      card-body
    />
  </BCard>
</template>

<script>
import { onMounted } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import { onProfileChangedRedirectToIndex } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import ImportSummary from '~/components/imports/ImportSummary.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    BCard,
    ImportSummary,
    PageHeader,
    TransactionsList,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.show');
    const importsPath = importsApi.index.path();

    const transactionStore = useTransactionStore();
    const paginationStore = usePaginationStore();

    const { transactions } = storeToRefs(transactionStore);
    const { pagination } = storeToRefs(paginationStore);

    onMounted(() => {
      transactionStore.setFetchParams({ importId: props.importObject.id, daysToShow: 0, startDate: null, endDate: null });
      transactionStore.fetchCollection();
    });

    onProfileChangedRedirectToIndex(importsApi);

    return {
      t,
      importsPath,
      transactions,
      pagination,
    };
  },
};
</script>
