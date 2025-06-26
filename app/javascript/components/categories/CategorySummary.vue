<template>
  <BCard :title="`${t('sub_header_summary')} ${month} ${year}`">
    <LoadingOverlay
      :loading="loading"
      class="CategorySummary__card-body p-2"
    >
      <div class="row">
        <div class="col-6">
          <h5 class="m-0">
            {{ t('money_in') }}
          </h5>
          <span class="fs-3 fw-bold text-credit">
            {{ category.summary.creditAmount }}
          </span>
        </div>

        <div class="col-6">
          <h5 class="m-0">
            {{ t('expenses') }}
          </h5>
          <span class="fs-3 fw-bold text-debit">
            {{ category.summary.debitAmount }}
          </span>
        </div>
      </div>

      <template v-if="!!budgetInstance">
        <h4 class="CategorySummary__card-body-subtitle">
          {{ t('budget_label') }}
        </h4>

        <div class="row mt-3">
          <div class="col-6">
            <h5 class="m-0">
              {{ t('used_budget_label') }}
            </h5>
            <span class="fs-3 fw-bold">
              {{ formatMoney(budgetInstance.usedAmount) }} / {{ formatMoney(budgetInstance.limitAmount) }}
            </span>
          </div>

          <div class="col-6">
            <h5 class="m-0">
              {{ t('remaining_budget_label') }}
            </h5>
            <span
              class="fs-3 fw-bold"
              :class="{ 'text-debit': remainderLimit < 0, 'text-credit': remainderLimit >= 0 }"
            >
              {{ formatMoney(remainderLimit) }}
            </span>
          </div>
        </div>
      </template>
    </LoadingOverlay>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import BCard from '~/components/bootstrap/BCard.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    BCard,
    LoadingOverlay,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.categories.show');
    const dateRangeStore = useDateRangeStore();
    const budgetInstanceStore = useBudgetInstanceStore();

    const { budgetInstanceForCategory } = storeToRefs(budgetInstanceStore);
    const { startMonth: month, startYear: year } = storeToRefs(dateRangeStore);
    const budgetInstance = computed(() => {
      return budgetInstanceForCategory.value(props.category);
    });

    const remainderLimit = computed(() => (budgetInstance.value?.limitAmount ?? 0) - (budgetInstance.value?.usedAmount ?? 0));

    return {
      t,
      month,
      year,
      budgetInstance,
      remainderLimit,
      formatMoney,
    };
  },
};
</script>

<style lang="scss" scoped>
.CategorySummary__card-body-subtitle {
  margin: 1rem 0 2rem -0.5rem ;
}
</style>
