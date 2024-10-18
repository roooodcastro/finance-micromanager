<template>
  <NoRecordsFound
    v-if="!imports.length"
    class="m-3"
  />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :rows="imports"
      :actions="tableActions"
      :columns="tableColumns"
      :side-strip-color="sideStripColorFunction"
    >
      <template v-slot:default="{ row: importObject }">
        <ImportTableRow :import-object="importObject" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useImportStore from '~/stores/ImportStore.js';
import { COLORS_FOR_IMPORT_STATUSES } from '~/utils/Constants.js';

import ImportTableRow from '~/components/imports/ImportTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    GridTable,
    NoRecordsFound,
    ImportTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.imports_list');

    const importStore = useImportStore();

    const { imports } = storeToRefs(importStore);

    const tableActions = [];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('target_wallet_label'), side: 'left' },
      { label: t('status_label'), side: 'left' },
    ];

    const sideStripColorFunction = (row) => COLORS_FOR_IMPORT_STATUSES[row.status];

    return {
      imports,
      tableActions,
      tableColumns,
      sideStripColorFunction
    };
  },
};
</script>
