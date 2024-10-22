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
      <GridTable
        :rows="importNames"
        :columns="tableColumns"
        :actions="tableActions"
        searchable
        @search="handleSearch"
      >
        <template v-slot:default="{ row: importName }">
          <ImportNameTableRow :import-name="importName" />
        </template>
      </GridTable>
    </InfiniteScrolling>

    <Pagination
      v-if="!loading"
      class="d-none d-lg-flex my-3"
      @change="handlePageChange"
    />
  </LoadingOverlay>
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';
import { editAction, deleteAction } from '~/utils/GridTableUtils.js';

import ImportNameTableRow from '~/components/import_names/ImportNameTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import InfiniteScrolling from '~/components/layout/InfiniteScrolling.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import Pagination from '~/components/rails/Pagination.vue';
import GridTable from '~/components/ui/GridTable.vue';

export default {
  components: {
    GridTable,
    ImportNameTableRow,
    InfiniteScrolling,
    LoadingOverlay,
    NoRecordsFound,
    Pagination,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.import_names_list');

    const importNameStore = useImportNameStore();
    const paginationStore = usePaginationStore();

    const { importNames, loading, fetchParams } = storeToRefs(importNameStore);

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

    const handleSearch = (searchString) => {
      fetchParams.value.search_string = searchString;
      importNameStore.fetchCollection().then(() => loadingNextPage.value = false);
    };

    const tableActions = [editAction(importNameStore), deleteAction(importNameStore)];
    const tableColumns = [{ label: t('from_name_label'), side: 'left' }, { label: t('to_name_label'), side: 'right' }];

    return {
      importNames,
      loading,
      tableActions,
      tableColumns,
      handleSearch,
      handlePageChange,
      handleInfiniteScrolling,
    };
  },
};
</script>
