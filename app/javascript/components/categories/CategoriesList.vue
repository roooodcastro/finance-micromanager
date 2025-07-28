<template>
  <NoRecordsFound v-if="!orderedCategories.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :columns="categoryColumns"
      :rows="orderedCategories"
      :actions="categoryActions"
      :side-strip-color="sideStripColorFunction"
      bordered
      rounded
    >
      <template v-slot:default="{ row: category }">
        <CategoryTableRow :category="category" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import { editAction, disableAction, reenableAction } from '~/utils/GridTableUtils.js';

import CategoryTableRow from '~/components/categories/CategoryTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    CategoryTableRow,
    GridTable,
    NoRecordsFound,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.categories_list');

    const categoryStore = useCategoryStore();
    const { categories } = storeToRefs(categoryStore);

    const categoryActions = [
      {
        label: t('favourite_action_label'),
        icon: 'star',
        callback: row => categoryStore.update(row.id, { favourite: true }),
        variant: 'warning',
        show: row => !row.system && !row.disabledAt && !row.favourite
      },
      {
        label: t('unfavourite_action_label'),
        icon: ['far', 'star'],
        callback: row => categoryStore.update(row.id, { favourite: false }),
        variant: 'warning',
        show: row => !row.system && !row.disabledAt && row.favourite
      },
      editAction(categoryStore),
      disableAction(categoryStore),
      reenableAction(categoryStore),
    ];

    const categoryColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('subcategories_label'), side: 'left' },
    ];

    const sideStripColorFunction = row => row.color;

    const orderedCategories = computed(() => {
      return categories.value.toSorted((a, b) => {
        if (b.favourite - a.favourite !== 0) {
          return b.favourite - a.favourite;
        } else {
          return a.name.localeCompare(b.name);
        }
      });
    });

    return {
      orderedCategories,
      categoryColumns,
      categoryActions,
      sideStripColorFunction,
    };
  },
};
</script>
