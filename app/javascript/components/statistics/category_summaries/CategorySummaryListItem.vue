<template>
  <div class="list-group-item border-bottom">
    <div class="row align-items-center">
      <div class="col-7 col-md-9 col-lg-8 col-xl-9 d-flex align-items-stretch text-decoration-none text-body">
        <span
          class="CategoriesList__color-indicator me-2"
          :style="{ backgroundColor: category.color }"
        />
        <span class="py-2">
          <FontAwesomeIcon
            v-if="category.subcategories.length > 0"
            :icon="expanded ? 'circle-minus' : 'circle-plus'"
            class="text-muted"
            @click="handleSubcategoryTogglerClick"
          />

          <a
            :href="showCategoryPath(category.id)"
            class="text-body ms-2"
          >
            {{ category.name }}
          </a>
        </span>
      </div>

      <div
        class="col text-end fw-bold me-2"
        :class="{ 'text-credit': totalSum > 0, 'text-debit': totalSum < 0 }"
      >
        {{ formatMoney(totalSum) }}
      </div>
    </div>

    <div
      class="CategorySummaryListItem__subcategoriesContainer row align-items-center"
      :class="{ 'show': expanded }"
    >
      <div class="min-height-0">
        <CategorySummaryListSubcategoryRow
          :amount="rootCategorySum"
          :label="category.name"
          :indicator-color="category.color"
        />

        <CategorySummaryListSubcategoryRow
          v-for="(subcategory, index) in category.subcategories"
          :key="`${subcategory.id}-${rangeKey}`"
          :amount="summarySumFor(subcategory)"
          :label="subcategory.displayName"
          :indicator-color="category.color"
          :last-child="index + 1 === category.subcategories.length"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { formatMoney } from '~/utils/NumberFormatter.js';
import { categories as categoriesApi } from '~/api/all.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import { getValueFromJsonCookie, setValueToJsonCookie } from '~/utils/CookieUtils.js';
import { DISPLAY_OPTIONS_COOKIE_NAME } from '~/utils/Constants.js';

import CategorySummaryListSubcategoryRow from '~/components/statistics/category_summaries/CategorySummaryListSubcategoryRow.vue';

export default {
  components: {
    CategorySummaryListSubcategoryRow,
    FontAwesomeIcon
  },
  props: {
    summaries: {
      type: Object,
      required: true,
    },
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const dateRangeStore = useDateRangeStore();
    const { rangeKey } = storeToRefs(dateRangeStore);

    const expanded = ref(getValueFromJsonCookie(DISPLAY_OPTIONS_COOKIE_NAME,
        `category_summary_expanded_${props.category.id}`));

    const showCategoryPath = (categoryId) => categoriesApi.show.path({ id: categoryId });

    const mainCategorySummary = computed(() => props.summaries.filter(summary => !summary.subcategoryId)?.at(0));
    const subcategorySummaries = computed(() => props.summaries.filter(summary => summary.subcategoryId));
    const totalSum = computed(() => _.sumBy(props.summaries, summary => summary.debitSum + summary.creditSum));
    const rootCategorySum = computed(() => {
      return mainCategorySummary.value ? mainCategorySummary.value.debitSum + mainCategorySummary.value.creditSum : 0;
    });

    const summarySumFor = (subcategory) => {
      const summary = props.summaries.find(summary => summary.subcategoryId === subcategory.id);
      return summary ? summary.debitSum + summary.creditSum : 0;
    };

    const subcategoryName = (summary) => {
      return props.category.subcategories.find(subcat => subcat.id === summary.subcategoryId).displayName;
    };

    const handleSubcategoryTogglerClick = () => {
      expanded.value = !expanded.value;
      setValueToJsonCookie(
        DISPLAY_OPTIONS_COOKIE_NAME, `category_summary_expanded_${props.category.id}`, expanded.value
      );
    };

    return {
      expanded,
      rangeKey,
      mainCategorySummary,
      subcategorySummaries,
      totalSum,
      rootCategorySum,
      summarySumFor,
      showCategoryPath,
      subcategoryName,
      formatMoney,
      handleSubcategoryTogglerClick,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../../stylesheets/variables';

.CategoriesList__color-indicator {
  display: inline-block;
  width: 0.5em;
}

.CategorySummaryListItem__subcategoriesContainer {
  display: grid;
  grid-template-rows: 0fr;
  overflow: hidden;
  transition: grid-template-rows 0.3s;

  &.show {
    grid-template-rows: 1fr;
  }
}
</style>
