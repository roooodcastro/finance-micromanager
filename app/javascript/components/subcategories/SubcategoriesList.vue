<template>
  <GridTable
    :rows="subcategories"
    :actions="tableActions"
    :columns="tableColumns"
  >
    <template v-slot:default="{ row: subcategory }">
      <SubcategoryTableRow
        :category="category"
        :subcategory="subcategory"
      />
    </template>
  </GridTable>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import { reenableAction } from '~/utils/GridTableUtils.js';

import SubcategoryTableRow from '~/components/subcategories/SubcategoryTableRow.vue';
import GridTable from '~/components/ui/GridTable.vue';

export default {
  components: {
    GridTable,
    SubcategoryTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.subcategories_list');

    const subcategoryStore = useSubcategoryStore();
    const categoryStore = useCategoryStore();
    const { subcategories } = storeToRefs(subcategoryStore);
    const { category } = storeToRefs(categoryStore);

    const tableActions = [
      {
        label: I18n.t('views.layout.grid_table.edit_action_label'),
        icon: 'pen-to-square',
        callback: row => subcategoryStore.openFormModal(row.id),
        variant: 'secondary',
        show: row => !row.disabledAt
      },
      {
        label: I18n.t('views.layout.grid_table.disable_action_label'),
        icon: 'ban',
        callback: row => subcategoryStore.disable(category.value.id, row.id),
        variant: 'danger',
        show: row => !row.disabledAt
      },
      reenableAction(subcategoryStore),
    ];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('balance_label'), side: 'right', align: 'right' },
    ];

    return {
      category,
      subcategories,
      tableActions,
      tableColumns,
    };
  },
};
</script>
