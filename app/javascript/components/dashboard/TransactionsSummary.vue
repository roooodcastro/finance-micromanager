<template>
  <h4 class="card-title m-0 d-none d-md-block">
    {{ t('sub_header_transactions_summary') }}
  </h4>

  <template v-if="!initialFetchDone">
    <div class="row">
      <div class="col placeholder-glow">
        <span class="placeholder col-6 fs-3" />
        <div>
          <span class="placeholder col-6 fs-3 mt-1" />
        </div>
      </div>
    </div>

    <div class="row mt-5">
      <div class="placeholder-glow col-6">
        <h5 class="m-0">
          {{ t('money_in') }}
        </h5>
        <span class="placeholder col-6 fs-3" />
      </div>

      <div class="placeholder-glow col-6">
        <h5 class="m-0">
          {{ t('spends') }}
        </h5>
        <span class="placeholder col-6 fs-3" />
      </div>
    </div>
  </template>

  <template v-else>
    <div class="row">
      <div class="col">
        <span class="fs-1 fw-bold">
          {{ formatMoney(endBalance) }}
        </span>
        <div class="fs-5 d-flex gap-2 lh-1">
          <span
            class="fw-bold"
            :class="{ 'text-credit': balanceDiff >= 0, 'text-debit': balanceDiff < 0 }"
          >
            {{ formatMoney(balanceDiff, { signDisplay: 'always' }) }}
          </span>
          <span class="text-muted">
            {{ t('from_last_month_label') }}
          </span>
        </div>
      </div>
    </div>

    <div
      class="row"
      :class="{ 'mt-4': !!budgetInstance, 'mt-5': !budgetInstance }"
    >
      <div class="col-6">
        <h5 class="m-0">
          {{ t('money_in') }}
        </h5>
        <span class="fs-3 fw-bold text-credit">
          {{ formatMoney(statistics.moneyIn) }}
        </span>
      </div>

      <div class="col-6">
        <h5 class="m-0">
          {{ t('spends') }}
        </h5>
        <span class="fs-3 fw-bold text-debit">
          {{ formatMoney(statistics.spends * -1) }}
        </span>
      </div>
    </div>

    <div
      v-if="!!budgetInstance"
      class="row mt-3"
    >
      <div class="col-6">
        <h5 class="m-0">
          {{ t('budget_limit') }}
        </h5>
        <span class="fs-3 fw-bold">
          {{ formatMoney(budgetInstance.limitAmount) }}
        </span>
      </div>

      <div class="col-6">
        <h5 class="m-0">
          {{ t('remaining_limit') }}
        </h5>
        <span
          class="fs-3 fw-bold"
          :class="{ 'text-credit': budgetInstance.remainingAmount > 0, 'text-debit': budgetInstance.remainingAmount < 0}"
        >
          {{ formatMoney(budgetInstance.remainingAmount) }}
        </span>
      </div>
    </div>
  </template>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';

import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  setup() {
    const t = I18n.scopedTranslator('views.dashboard.show');

    const transactionStore = useTransactionStore();
    const budgetInstanceStore = useBudgetInstanceStore();

    const { statistics, loading, initialFetchDone } = storeToRefs(transactionStore);
    const { budgetInstanceForProfile: budgetInstance } = storeToRefs(budgetInstanceStore);

    const startBalance = computed(() => statistics.value.startBalance);
    const endBalance = computed(() => statistics.value.endBalance);
    const balanceDiff = computed(() => endBalance.value - startBalance.value);

    return {
      t,
      loading,
      initialFetchDone,
      statistics,
      startBalance,
      endBalance,
      balanceDiff,
      formatMoney,
      budgetInstance,
    };
  },
};
</script>
