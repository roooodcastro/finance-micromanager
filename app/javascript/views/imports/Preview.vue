<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  <ImportPreviewSummary :import-object="importObject" />

  <ImportPreviewForm :import-object="importObject">
    <ImportPreviewList />

    <ImportPreviewActions />
  </ImportPreviewForm>

  <ImportNameForm />
</template>

<script>
import { onMounted, watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportStore from '~/stores/ImportStore.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ImportPreviewForm from '~/components/imports/ImportPreviewForm.vue';
import ImportPreviewList from '~/components/imports/ImportPreviewList.vue';
import ImportPreviewSummary from '~/components/imports/ImportPreviewSummary.vue';
import ImportPreviewActions from '~/components/imports/ImportPreviewActions.vue';
import ImportNameForm from '~/components/import_names/ImportNameForm.vue';

export default {
  components: {
    ImportNameForm,
    ImportPreviewActions,
    ImportPreviewForm,
    ImportPreviewList,
    ImportPreviewSummary,
    PageHeader,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
    importTransactions: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');
    const importsPath = importsApi.index.path();

    const importStore = useImportStore();
    const importNameStore = useImportNameStore();
    const transactionPredictionStore = useTransactionPredictionStore();

    importStore.loadImportTransactionsFromProps(props.importObject, props.importTransactions);

    const { importNames } = storeToRefs(importNameStore);
    const { transactionPredictions } = storeToRefs(transactionPredictionStore);

    onMounted(() => {
      if (!importNames.value.length) {
        importNameStore.fetchCollection();
      }

      if (!transactionPredictions.value.length) {
        transactionPredictionStore.fetchCollection();
      }
    });

    // TODO: fetchCollection below is not refreshing the form table
    // create index endpoint for import_transactions, create importTransactionStore, fetchCollection from there instead
    watch(importNames, (_, oldImportNames) => {
      if (oldImportNames.length) {
        importStore.fetchCollection();
      }
    });

    return {
      t,
      importsPath,
    };
  },
};
</script>
