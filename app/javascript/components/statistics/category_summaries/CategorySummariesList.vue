<template>
  <LoadingOverlay :loading="loading">
    <NoRecordsFound
      v-if="!filteredCategories.length"
      class="m-3"
    />

    <div v-else>
      <template
        v-for="category in filteredCategories"
        :key="`${category.id}-${rangeKey}`"
      >
        <CategorySummaryListItem
          :summaries="indexedSummaries[category.id] ?? []"
          :category="category"
        />
      </template>
    </div>
  </LoadingOverlay>
</template>

<script>
import { computed } from 'vue';
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

    const filteredCategories = computed(() => {
      const favouriteCategories = categories.value.filter(category => category.favourite);
      if (favouriteCategories.length) {
        return favouriteCategories;
      } else {
        return categories.value;
      }
    });

    return {
      loading,
      rangeKey,
      filteredCategories,
      indexedSummaries,
    };
  },
};
</script>
