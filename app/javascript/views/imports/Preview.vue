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
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
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
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');
    const importsPath = importsApi.index.path();

    const importStore = useImportStore();
    const importTransactionStore = useImportTransactionStore();
    const importNameStore = useImportNameStore();
    const transactionPredictionStore = useTransactionPredictionStore();

    importStore.loadImportFromProps(props.importObject);

    const { importNames, fetchParams: importNameFetchParams } = storeToRefs(importNameStore);
    const { importTransactions, urlParams: importTransactionUrlParams } = storeToRefs(importTransactionStore);
    const { transactionPredictions } = storeToRefs(transactionPredictionStore);

    onMounted(() => {
      if (!importNames.value.length) {
        importNameFetchParams.value.fetchAll = true;
        importNameStore.fetchCollection();
      }

      if (!importTransactions.value.length) {
        importTransactionUrlParams.value.importId = props.importObject.id;
        importTransactionStore.fetchCollection();
      }

      if (!transactionPredictions.value.length) {
        transactionPredictionStore.fetchCollection();
      }
    });

    watch(importNames, (_, oldImportNames) => {
      if (oldImportNames.length) {
        importTransactionStore.fetchCollection();
      }
    });

    return {
      t,
      importsPath,
    };
  },
};
</script>
