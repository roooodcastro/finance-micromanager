<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  <ImportPreviewSummary
    :import-object="importObject"
    class="mb-3"
  />

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
import useShortcutStore from '~/stores/ShortcutStore.js';

import {
  IMPORT_ACTION_IMPORT,
  IMPORT_ACTION_SKIP,
} from '~/utils/Constants.js';

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
    const shortcutStore = useShortcutStore();
    const importNameStore = useImportNameStore();
    const importTransactionStore = useImportTransactionStore();
    const transactionPredictionStore = useTransactionPredictionStore();

    importStore.loadImportFromProps(props.importObject);

    const { importNames, fetchParams: importNameFetchParams } = storeToRefs(importNameStore);
    const { importTransactions, urlParams: importTransactionUrlParams } = storeToRefs(importTransactionStore);
    const { transactionPredictions } = storeToRefs(transactionPredictionStore);

    // Shortcuts
    shortcutStore.registerShortcut('alt+,', 'import_preview_prev', ['alt', '<'], () => importTransactionStore.moveCursorFromShortcut(-1));
    shortcutStore.registerShortcut('alt+.', 'import_preview_next', ['alt', '>'], () => importTransactionStore.moveCursorFromShortcut(1));
    shortcutStore.registerShortcut('alt+i', 'import_preview_import', ['alt', 'i'], () => importTransactionStore.setActionFromShortcut(IMPORT_ACTION_IMPORT));
    shortcutStore.registerShortcut('alt+x', 'import_preview_skip', ['alt', 'x'], () => importTransactionStore.setActionFromShortcut(IMPORT_ACTION_SKIP));

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
