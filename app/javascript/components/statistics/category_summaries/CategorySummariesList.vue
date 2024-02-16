<template>
  <LoadingOverlay :loading="loading">
    <NoRecordsFound
      v-if="!categories.length"
      class="m-3"
    />

    <div
      v-else
      class="CategorySummariesList"
    >
      <template
        v-for="category in categories"
        :key="`${category.id}-${rangeKey}`"
      >
        <CategorySummaryListItem
          v-if="!!indexedSummaries[category.id]"
          :summaries="indexedSummaries[category.id]"
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
import useDateRangeStore from '~/stores/DateRangeStore.js';

import CategorySummaryListItem from '~/components/statistics/category_summaries/CategorySummaryListItem.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    CategorySummaryListItem,
    LoadingOverlay,
    NoRecordsFound,
  },

  setup() {
    const categoryStore = useCategoryStore();
    const dateRangeStore = useDateRangeStore();
    const categorySummaryStore = useStatisticsCategorySummaryStore();

    const { categories } = storeToRefs(categoryStore);
    const { rangeKey } = storeToRefs(dateRangeStore);
    const { indexedSummaries, loading } = storeToRefs(categorySummaryStore);

    return {
      loading,
      rangeKey,
      categories,
      indexedSummaries,
    };
  },
};
</script>
