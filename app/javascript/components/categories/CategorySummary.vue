<template>
  <div class="card">
    <div class="card-header">
      <h5 class="m-0">
        {{ t('sub_header_summary') }}
      </h5>
    </div>
    <div class="CategorySummary__card-body card-body d-grid gap-2 p-2">
      <div class="card bg-success-subtle text-success-emphasis border-0">
        <div class="card-body">
          <h5 class="card-title">
            {{ t('money_in') }}
          </h5>

          <span class="fs-1">
            {{ category.summary.creditAmount }}
          </span>
        </div>
      </div>

      <div class="card bg-danger-subtle text-danger-emphasis border-0">
        <div class="card-body">
          <h5 class="card-title">
            {{ t('expenses') }}
          </h5>

          <span class="fs-1">
            {{ category.summary.debitAmount }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return { t: I18n.scopedTranslator('views.categories.show') };
  },
};
</script>

<style lang="scss" scoped>
.CategorySummary__card-body {
  grid-template-columns: repeat(2, minmax(0, 1fr));
  grid-auto-flow: column;
}
</style>
