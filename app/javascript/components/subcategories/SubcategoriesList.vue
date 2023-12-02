<template>
  <div class="SubcategoriesList list-group overflow-hidden">
    <template
      v-for="subcategory in subcategories"
      :key="`${subcategory.id}_${subcategory.updatedAt}`"
    >
      <SubcategoryListItem :subcategory="subcategory" />
    </template>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import SubcategoryListItem from '~/components/subcategories/SubcategoryListItem.vue';

export default {
  components: {
    SubcategoryListItem,
  },

  setup() {
    const subcategoryStore = useSubcategoryStore();
    const { subcategories } = storeToRefs(subcategoryStore);

    return {
      subcategories,
    };
  },
};
</script>
