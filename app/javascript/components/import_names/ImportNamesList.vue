<template>
  <NoRecordsFound v-if="!importNames.length" />
  <div
    v-else
    class="list-group"
  >
    <template
      v-for="importName in importNames"
      :key="`${importName.id}_${importName.updatedAt}`"
    >
      <ImportNameListItem :import-name="importName" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useImportNameStore from '~/stores/ImportNameStore.js';

import ImportNameListItem from '~/components/import_names/ImportNameListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    ImportNameListItem,
  },

  setup() {
    const importNameStore = useImportNameStore();

    const { importNames } = storeToRefs(importNameStore);

    return {
      importNames,
    };
  },
};
</script>
