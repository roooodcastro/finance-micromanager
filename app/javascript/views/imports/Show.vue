<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  <ImportSummary
    :import-object="importObject"
    :imported-transactions="importedTransactions"
  />

  <BCard
    :title="t('imported_transactions_header', { count: importedTransactions.length})"
    class="mt-3"
    no-body
  >
    <SimpleTransactionsList
      :transactions="importedTransactions"
      card-body
    />
  </BCard>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import ImportSummary from '~/components/imports/ImportSummary.vue';
import SimpleTransactionsList from '~/components/transactions/SimpleTransactionsList.vue';

export default {
  components: {
    BCard,
    ImportSummary,
    PageHeader,
    SimpleTransactionsList,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
    importedTransactions: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.show');
    const importsPath = importsApi.index.path();

    return {
      t,
      importsPath,
    };
  },
};
</script>
