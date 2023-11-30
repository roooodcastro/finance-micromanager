<template>
  <div class="list-group-item bg-light-subtle">
    <div class="row border-bottom align-items-center">
      <a
        :href="showCategoryPath(category.id)"
        class="col-7 col-md-9 col-lg-8 col-xl-9 d-flex align-items-stretch text-decoration-none text-body bg-hover-light"
      >
        <span
          class="CategoriesList__color-indicator me-2"
          :style="{ backgroundColor: category.color }"
        />
        <span class="py-2">
          {{ category.name }}
        </span>
      </a>

      <div
        class="col text-end fw-bold me-2"
        :class="{ 'text-credit': totalSum > 0, 'text-debit': totalSum < 0 }"
      >
        {{ formatMoney(totalSum, summary?.currencySymbol) }}
      </div>
    </div>
  </div>
</template>

<script>
import { formatMoney } from '~/utils/NumberFormatter.js';
import { categories as categoriesApi } from '~/api';

export default {
  props: {
    summary: {
      type: Object,
      required: true,
    },
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const showCategoryPath = (categoryId) => categoriesApi.show.path({ id: categoryId });
    const totalSum = props.summary ? props.summary.debitSum + props.summary.creditSum : 0;

    return {
      showCategoryPath,
      formatMoney,
      totalSum,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../../stylesheets/variables';

.CategoriesList__color-indicator {
  border: 1px solid $table-border-color;
  display: inline-block;
  width: 0.5em;
}
</style>
