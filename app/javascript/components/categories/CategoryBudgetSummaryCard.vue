<template>
  <component
    :is="noCard ? 'div' : 'BCard'"
    no-body
  >
    <template v-slot:header>
      <h4 class="m-0">
        {{ t('sub_header_budget') }}
      </h4>
    </template>

    <div class="mx-md-3">
      <div class="row">
        <div class="col-6">
          <h6 class="m-0">
            {{ t('budget_used_label') }}
          </h6>
          <span
            class="fs-3 fw-bold"
            :class="{ 'text-debit': remainderLimit < 0, 'text-credit': remainderLimit > 0 }"
          >
            {{ formatMoney(budgetInstance.usedAmount + budgetInstance.carryoverAmount) }}
          </span>
        </div>


        <div class="col-6 text-end">
          <h6 class="m-0">
            {{ t('budget_limit_label') }}
          </h6>
          <span class="fs-3 fw-bold">
            {{ formatMoney(budgetInstance.limitAmount) }}
          </span>
        </div>
      </div>

      <div class="row mt-3">
        <div class="col-6">
          <h6 class="m-0">
            {{ t('budget_carryover_label') }}
          </h6>
          <span
            class="fs-3 fw-bold"
            :class="{ 'text-debit': budgetInstance.carryoverAmount < 0, 'text-credit': budgetInstance.carryoverAmount > 0 }"
          >
            {{ formatMoney(budgetInstance.carryoverAmount) }}
          </span>
        </div>

        <div class="col-6 text-end">
          <h6 class="m-0">
            {{ t('budget_remainder_label') }}
          </h6>
          <span
            class="fs-3 fw-bold"
            :class="{ 'text-debit': remainderLimit < 0, 'text-credit': remainderLimit >= 0 }"
          >
            {{ formatMoney(remainderLimit) }}
          </span>
        </div>
      </div>

      <h4 class="mt-5 mb-3">
        {{ t('sub_header_budget_history') }}
      </h4>

      <BudgetHistoryChart />
    </div>
  </component>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';

import BCard from '~/components/bootstrap/BCard.vue';
import BudgetHistoryChart from '~/components/budgets/BudgetHistoryChart.vue';

export default {
  components: {
    BCard,
    BudgetHistoryChart,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
    noCard: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.categories.show');

    const budgetInstanceStore = useBudgetInstanceStore();
    const { budgetInstanceForCategory } = storeToRefs(budgetInstanceStore);
    const budgetInstance = computed(() => budgetInstanceForCategory.value(props.category.id));

    const remainderLimit = computed(() => {
      return (budgetInstance.value?.limitAmount ?? 0) - (budgetInstance.value?.usedAmount ?? 0);
    });

    return {
      t,
      budgetInstance,
      remainderLimit,
      formatMoney,
    };
  },
};
</script>
