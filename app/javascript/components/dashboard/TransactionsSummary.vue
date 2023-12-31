<template>
  <CollapsibleCard
    id="transactions_summary"
    :title="t('sub_header_transactions_summary')"
  >
    <div class="row">
      <div class="col-12 col-md-7 col-lg-12 col-xl-7">
        <div class="card bg-light border-0">
          <div class="TransactionsSummary__grid card-body d-grid text-center gap-3">
            <div class="text-credit">
              <h6>{{ t('money_in') }}</h6>

              <span class="fs-4">
                {{ formatMoney(statistics.moneyIn) }}
              </span>
            </div>

            <div class="text-debit">
              <h6>{{ t('spends') }}</h6>

              <span class="fs-4">
                {{ formatMoney(statistics.spends * -1) }}
              </span>
            </div>

            <div :class="{ 'text-credit': moneySaved >= 0, 'text-debit': moneySaved < 0 }">
              <h6>{{ t('money_saved') }}</h6>

              <span class="fs-4">
                {{ formatMoney(moneySaved) }}
              </span>
            </div>

            <div class="text-debit">
              <h6>{{ t('average_spend') }}</h6>

              <span class="fs-4">
                {{ formatMoney(averageSpend) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-md-5 col-lg-12 col-xl-5">
        <MoneyInSpendsChart />
      </div>
    </div>
  </CollapsibleCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';

import CollapsibleCard from '~/components/bootstrap/CollapsibleCard.vue';
import MoneyInSpendsChart from '~/components/transactions/MoneyInSpendsChart.vue';
import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  components: {
    CollapsibleCard,
    MoneyInSpendsChart,
  },

  setup() {
    const t = I18n.scopedTranslator('views.dashboard.show');

    const dateRangeStore = useDateRangeStore();
    const transactionStore = useTransactionStore();
    const { statistics } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    const moneySaved = computed(() => statistics.value.moneyIn + statistics.value.spends);
    const averageSpend = computed(() => {
      const numberOfDays = Math.round(endDate.value.diff(startDate.value, 'day', true));
      return (statistics.value.spends / numberOfDays) * -1;
    });

    return {
      t,
      statistics,
      moneySaved,
      averageSpend,
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
