<template>
  <LoadingOverlay :loading="loading">
    <NoRecordsFound
      v-if="!importNames.length"
      class="m-3"
    />

    <InfiniteScrolling
      v-else
      @scroll="handleInfiniteScrolling"
    >
      <div class="list-group">
        <template
          v-for="importName in importNames"
          :key="`${importName.id}_${importName.updatedAt}`"
        >
          <ImportNameListItem :import-name="importName" />
        </template>
      </div>
    </InfiniteScrolling>

    <Pagination
      v-if="!loading"
      class="d-none d-lg-flex mt-3 me-2 me-lg-3 mb-2 mb-lg-3"
      @change="handlePageChange"
    />
  </LoadingOverlay>
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

import useImportNameStore from '~/stores/ImportNameStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';

import ImportNameListItem from '~/components/import_names/ImportNameListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import Pagination from '~/components/rails/Pagination.vue';

export default {
  components: {
    NoRecordsFound,
    ImportNameListItem,
    InfiniteScrolling,
    LoadingOverlay,
    Pagination,
  },

  setup() {
    const importNameStore = useImportNameStore();
    const paginationStore = usePaginationStore();

    const { importNames, loading } = storeToRefs(importNameStore);

    const loadingNextPage = ref(false);

    const handlePageChange = () => importNameStore.fetchCollection();

    const handleInfiniteScrolling = () => {
      if (isMediaBreakpointDown('md') && !loadingNextPage.value) {
        loadingNextPage.value = true;

        if (paginationStore.incrementPage()) {
          importNameStore.fetchCollection({ keepRecords: true }).then(() => loadingNextPage.value = false);
        }
      }
    };

    return {
      importNames,
      loading,
      handlePageChange,
      handleInfiniteScrolling,
    };
  },
};
</script>
