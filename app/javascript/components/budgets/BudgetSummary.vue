<template>
  <BCard :title="`${t('sub_header_summary')} ${month} ${year}`">
    <LoadingOverlay
      :loading="loading"
      class="BudgetSummary__card-body p-2"
    >
      <div class="row">
        <div class="col-12">
          <h5 class="m-0 text-muted">
            {{ t('limit_amount_label') }}
          </h5>
          <span class="fs-3 fw-bold">
            {{ formatMoney(budgetInstance?.limitAmount) }}
            (
            {{ budget.formattedLimit }}
            <template v-if="budget.limitType === BUDGET_LIMIT_TYPE_PERCENTAGE && !!budgetInstanceForProfile">
              {{ t('of_label') }}
              {{ formatMoney(budgetInstanceForProfile.limitAmount) }}
            </template>
            )
          </span>
        </div>
      </div>

      <div class="row mt-3">
        <div class="col-6">
          <h5 class="m-0 text-muted">
            {{ t('used_amount_label') }}
          </h5>
          <span class="fs-3 fw-bold">
            {{ formatMoney(budgetInstance?.usedAmount) }}
          </span>
        </div>

        <div class="col-6">
          <h5 class="m-0 text-muted">
            {{ t('remaining_amount_label') }}
          </h5>
          <span
            class="fs-3 fw-bold"
            :class="{ 'text-debit': remainderLimit < 0, 'text-credit': remainderLimit >= 0 }"
          >
            {{ formatMoney(remainderLimit) }}
          </span>
        </div>
      </div>

      <div
        v-if="budget.carryover"
        class="row mt-3"
      >
        <div class="col">
          <h5 class="m-0 text-muted">
            {{ t('carryover_label') }}
            {{ lastMonthLabel }}
          </h5>
          <span class="fs-3 fw-bold">
            {{ formatMoney(budgetInstance?.carryoverAmount) }}
          </span>
        </div>
      </div>
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
import { BUDGET_LIMIT_TYPE_PERCENTAGE } from '~/utils/Constants.js';

import BCard from '~/components/bootstrap/BCard.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    BCard,
    LoadingOverlay,
  },

  props: {
    budget: {
      type: Object,
      required: true,
    },
    budgetInstance: {
      type: Object,
      default: () => {},
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.budgets.show');
    const dateRangeStore = useDateRangeStore();
    const budgetInstanceStore = useBudgetInstanceStore();

    const { startMonth: month, startYear: year, startDate } = storeToRefs(dateRangeStore);
    const { budgetInstanceForProfile } = storeToRefs(budgetInstanceStore);

    const lastMonthLabel = computed(() => startDate.value.subtract(1, 'month').format('MMM YYYY'));

    const remainderLimit = computed(() => {
      return (props.budgetInstance?.limitAmount ?? 0) - (props.budgetInstance?.usedAmount ?? 0);
    });

    return {
      t,
      month,
      year,
      remainderLimit,
      formatMoney,
      lastMonthLabel,
      budgetInstanceForProfile,
      BUDGET_LIMIT_TYPE_PERCENTAGE,
    };
  },
};
</script>

<style lang="scss" scoped>
.BudgetSummary__card-body-subtitle {
  margin: 1rem 0 2rem -0.5rem ;
}
</style>
