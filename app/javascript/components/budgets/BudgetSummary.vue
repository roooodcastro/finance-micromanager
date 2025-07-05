<template>
  <BCard>
    <template v-slot:header>
      <h4 class="card-title m-0">
        {{ t('sub_header_summary') }}
        {{ month }}
        {{ year }}
        <DisabledBadge v-if="isDisabled" />
      </h4>
    </template>
    <LoadingOverlay
      :loading="loading"
      class="BudgetSummary__card-body p-2"
    >
      <InfoAlert
        v-if="!budgetInstance"
        :message="t('no_budget_info_message')"
      />
      <template v-else>
        <div class="row">
          <div class="col-12">
            <h5 class="m-0 text-muted">
              {{ t('limit_amount_label') }}
            </h5>
            <span class="fs-3 fw-bold">
              {{ formatMoney(budgetInstance?.limitAmount) }}
              <template v-if="budget.limitType !== BUDGET_LIMIT_TYPE_ABSOLUTE">
                (
                {{ budget.formattedLimit }}
                <template v-if="budget.limitType === BUDGET_LIMIT_TYPE_PERCENTAGE && !!budgetInstanceForProfile">
                  {{ t('of_label') }}
                  {{ formatMoney(budgetInstanceForProfile.limitAmount) }}
                </template>
                )
              </template>
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
              :class="{ 'text-debit': budgetInstance?.remainingAmount < 0, 'text-credit': budgetInstance?.remainingAmount >= 0 }"
            >
              {{ formatMoney(budgetInstance?.remainingAmount) }}
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
import { BUDGET_LIMIT_TYPE_ABSOLUTE, BUDGET_LIMIT_TYPE_PERCENTAGE } from '~/utils/Constants.js';

import BCard from '~/components/bootstrap/BCard.vue';
import DisabledBadge from '~/components/bootstrap/DisabledBadge.vue';
import InfoAlert from '~/components/bootstrap/InfoAlert.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    BCard,
    DisabledBadge,
    InfoAlert,
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

    const isDisabled = computed(() => !!props.budget.disabledAt);
    const lastMonthLabel = computed(() => startDate.value.subtract(1, 'month').format('MMM YYYY'));

    return {
      t,
      month,
      year,
      isDisabled,
      formatMoney,
      lastMonthLabel,
      budgetInstanceForProfile,
      BUDGET_LIMIT_TYPE_ABSOLUTE,
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
