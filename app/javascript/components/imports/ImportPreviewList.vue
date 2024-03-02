<template>
  <NoRecordsFound
    v-if="!previewData.length"
    class="m-3"
  />
  <div
    v-else
    class="list-group"
  >
    <template
      v-for="transaction in previewData"
      :key="`${transaction.rawName}_${transaction.transactionDate}`"
    >
      <ImportPreviewListItem :transaction="transaction" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useImportStore from '~/stores/ImportStore.js';

import ImportPreviewListItem from '~/components/imports/ImportPreviewListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    ImportPreviewListItem,
  },

  setup() {
    const importStore = useImportStore();
    const { previewData } = storeToRefs(importStore);

    return {
      previewData,
    };
  },
};
</script>
