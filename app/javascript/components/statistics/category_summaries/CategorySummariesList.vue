<template>
  <div>
    <div class="CategorySummariesList">
      <template
        v-for="category in categories"
        :key="indexedSummaries[category.id].id"
      >
        <CategorySummaryListItem
          :summary="indexedSummaries[category.id]"
          :category="category"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useStatisticsCategorySummaryStore from '~/stores/statistics/CategorySummaryStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import CategorySummaryListItem from '~/components/statistics/category_summaries/CategorySummaryListItem.vue';

export default {
  components: {
    CategorySummaryListItem,
  },

  setup() {
    const categoryStore = useCategoryStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();

    const { categories } = storeToRefs(categoryStore);
    const { indexedSummaries } = storeToRefs(categorySummaryStore);

    return {
      categories,
      indexedSummaries,
    };
  },
};
</script>
