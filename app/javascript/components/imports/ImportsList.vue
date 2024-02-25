<template>
  <NoRecordsFound
    v-if="!imports.length"
    class="m-3"
  />
  <div
    v-else
    class="list-group"
  >
    <template
      v-for="importObject in imports"
      :key="`${importObject.id}_${importObject.updatedAt}`"
    >
      <ImportListItem :import-object="importObject" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useImportStore from '~/stores/ImportStore.js';

import ImportListItem from '~/components/imports/ImportListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    NoRecordsFound,
    ImportListItem,
  },

  setup() {
    const importStore = useImportStore();

    const { imports } = storeToRefs(importStore);

    return {
      imports,
    };
  },
};
</script>
