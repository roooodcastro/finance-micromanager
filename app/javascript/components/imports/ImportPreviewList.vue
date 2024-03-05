<template>
  <NoRecordsFound
    v-if="!previewData.length"
    class="m-3"
  />
  <table
    v-else
    class="table table-sm"
  >
    <thead>
      <tr>
        <th>{{ t('name_label') }}</th>
        <th>{{ t('amount_label') }}</th>
        <th>{{ t('date_label') }}</th>
        <th>{{ t('category_label') }}</th>
        <th>{{ t('actions_label') }}</th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="transaction in previewData"
        :key="`${transaction.rawName}_${transaction.transactionDate}`"
      >
        <ImportPreviewListItem :transaction="transaction" />
      </template>
    </tbody>
  </table>
</template>

<script>
import { storeToRefs } from 'pinia';

import useImportStore from '~/stores/ImportStore.js';
import I18n from '~/utils/I18n.js';

import ImportPreviewListItem from '~/components/imports/ImportPreviewListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    ImportPreviewListItem,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.preview');

    const importStore = useImportStore();
    const { previewData } = storeToRefs(importStore);

    return {
      t,
      previewData,
    };
  },
};
</script>
