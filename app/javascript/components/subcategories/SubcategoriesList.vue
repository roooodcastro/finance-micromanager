<template>
  <div class="SubcategoriesList list-group list-group-flush overflow-hidden">
    <template
      v-for="subcategory in subcategories"
      :key="`${subcategory.id}_${subcategory.updatedAt}`"
    >
      <SubcategoryListItem
        :category="category"
        :subcategory="subcategory"
      />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import SubcategoryListItem from '~/components/subcategories/SubcategoryListItem.vue';

export default {
  components: {
    SubcategoryListItem,
  },

  setup() {
    const subcategoryStore = useSubcategoryStore();
    const categoryStore = useCategoryStore();
    const { subcategories } = storeToRefs(subcategoryStore);
    const { category } = storeToRefs(categoryStore);

    return {
      category,
      subcategories,
    };
  },
};
</script>
