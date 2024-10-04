<template>
  <BCard
    id="transactions_summary"
    :title="t('sub_header_transactions_summary')"
    :loading="loading && initialFetchDone"
  >
    <div
      v-if="!initialFetchDone"
      class="row"
    >
      <div class="col-12 col-md-8 col-lg-12 col-xl-8">
        <div class="card bg-light border-0">
          <div class="TransactionsSummary__grid card-body d-grid text-center gap-3">
            <div class="placeholder-glow pb-2">
              <h5>{{ t('money_in') }}</h5>
              <span class="placeholder col-6 fs-2" />
            </div>

            <div class="placeholder-glow pb-2">
              <h5>{{ t('spends') }}</h5>
              <span class="placeholder col-6 fs-2" />
            </div>

            <div class="placeholder-glow pb-2">
              <h5>{{ t('money_saved') }}</h5>
              <span class="placeholder col-6 fs-2" />
            </div>

            <div class="placeholder-glow pb-2">
              <h5>{{ t('average_spend') }}</h5>
              <span class="placeholder col-6 fs-2" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-else
      class="row"
    >
      <div class="col-12 col-md-8 col-lg-12 col-xl-8">
        <div class="card bg-light border-0">
          <div class="TransactionsSummary__grid card-body d-grid text-center gap-3">
            <div class="text-credit">
              <h5>{{ t('money_in') }}</h5>

              <span class="fs-3">
                {{ formatMoney(statistics.moneyIn) }}
              </span>
            </div>

            <div class="text-debit">
              <h5>{{ t('spends') }}</h5>

              <span class="fs-3">
                {{ formatMoney(statistics.spends * -1) }}
              </span>
            </div>

            <div :class="{ 'text-credit': moneySaved >= 0, 'text-debit': moneySaved < 0 }">
              <h5>{{ t('money_saved') }}</h5>

              <span class="fs-3">
                {{ formatMoney(moneySaved) }}
              </span>
            </div>

            <div class="text-debit">
              <h5>{{ t('average_spend') }}</h5>

              <span class="fs-3">
                {{ formatMoney(averageSpend) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-md-4 col-lg-12 col-xl-4">
        <StartEndBalancesChart />
      </div>
    </div>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';

import BCard from '~/components/bootstrap/BCard.vue';
import StartEndBalancesChart from '~/components/transactions/StartEndBalancesChart.vue';
import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  components: {
    BCard,
    StartEndBalancesChart,
  },

  setup() {
    const t = I18n.scopedTranslator('views.dashboard.show');

    const dateRangeStore = useDateRangeStore();
    const transactionStore = useTransactionStore();
    const { statistics, loading, initialFetchDone } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    const startBalance = computed(() => statistics.value.startBalance);
    const endBalance = computed(() => statistics.value.endBalance);
    const moneySaved = computed(() => statistics.value.moneyIn + statistics.value.spends);
    const averageSpend = computed(() => {
      const numberOfDays = Math.round(endDate.value.diff(startDate.value, 'day', true));
      return (statistics.value.spends / numberOfDays) * -1;
    });

    return {
      t,
      loading,
      initialFetchDone,
      statistics,
      moneySaved,
      averageSpend,
      startBalance,
      endBalance,
      formatMoney,
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionsSummary__grid {
  grid-template-columns: repeat(2, 1fr);
}
</style>
