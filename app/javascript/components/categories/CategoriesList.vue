<template>
  <NoRecordsFound v-if="!categories.length" />
  <BCard
    v-else
    no-body
    class="p-2"
  >
    <GridTable
      :columns="categoryColumns"
      :rows="categories"
      :actions="categoryActions"
      :side-strip-color="sideStripColorFunction"
    >
      <template v-slot:default="{ row: category }">
        <CategoryTableRow :category="category" />
      </template>
    </GridTable>
  </BCard>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
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

    // Load categories from props
    const { categories } = storeToRefs(categoryStore);

    // Reload categories if profile has changed while this list is shown
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => categoryStore.fetchCollection());

    const categoryActions = [
      editAction(categoryStore),
      disableAction(categoryStore),
      reenableAction(categoryStore),
    ];

    const categoryColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('subcategories_label'), side: 'left' },
    ];

    const sideStripColorFunction = row => row.color;

    return {
      categories,
      categoryColumns,
      categoryActions,
      sideStripColorFunction,
    };
  },
};
</script>
