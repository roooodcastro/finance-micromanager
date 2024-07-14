<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  <ImportPreviewSummary :import-object="importObject" />

  <ImportPreviewList />
</template>

<script>
import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportStore from '~/stores/ImportStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ImportPreviewList from '~/components/imports/ImportPreviewList.vue';
import ImportPreviewSummary from '~/components/imports/ImportPreviewSummary.vue';

export default {
  components: {
    ImportPreviewList,
    ImportPreviewSummary,
    PageHeader,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
    previewData: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');
    const importsPath = importsApi.index.path();

    const importStore = useImportStore();
    importStore.loadPreviewDataFromProps(props.previewData);

    return {
      t,
      importsPath,
    };
  },
};
</script>
