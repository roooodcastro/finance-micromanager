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
</template>

<script>
import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportStore from '~/stores/ImportStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ImportPreviewForm from '~/components/imports/ImportPreviewForm.vue';
import ImportPreviewList from '~/components/imports/ImportPreviewList.vue';
import ImportPreviewSummary from '~/components/imports/ImportPreviewSummary.vue';
import ImportPreviewActions from '~/components/imports/ImportPreviewActions.vue';

export default {
  components: {
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
    importStore.loadImportTransactionsFromProps(props.importObject, props.importTransactions);

    return {
      t,
      importsPath,
    };
  },
};
</script>
