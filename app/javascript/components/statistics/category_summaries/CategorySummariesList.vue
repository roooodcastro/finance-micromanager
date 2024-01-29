<template>
  <LoadingOverlay :loading="loading">
    <div class="CategorySummariesList">
      <template
        v-for="category in categories"
        :key="indexedSummaries[category.id]?.id"
      >
        <CategorySummaryListItem
          v-if="!!indexedSummaries[category.id]"
          :summary="indexedSummaries[category.id]"
          :category="category"
        />
      </template>
    </div>
  </LoadingOverlay>
</template>

<script>
import { storeToRefs } from 'pinia';

import useStatisticsCategorySummaryStore from '~/stores/statistics/CategorySummaryStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import CategorySummaryListItem from '~/components/statistics/category_summaries/CategorySummaryListItem.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    LoadingOverlay,
    CategorySummaryListItem,
  },

  setup() {
    const categoryStore = useCategoryStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();

    const { categories } = storeToRefs(categoryStore);
    const { indexedSummaries, loading } = storeToRefs(categorySummaryStore);

    return {
      loading,
      categories,
      indexedSummaries,
    };
  },
};
</script>
