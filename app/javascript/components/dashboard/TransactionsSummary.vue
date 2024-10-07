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
      <div class="col-12">
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

        <div class="row mt-5">
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
      </div>
    </div>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import BCard from '~/components/bootstrap/BCard.vue';
import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  components: {
    BCard,
  },

  setup() {
    const t = I18n.scopedTranslator('views.dashboard.show');

    const transactionStore = useTransactionStore();
    const { statistics, loading, initialFetchDone } = storeToRefs(transactionStore);

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
    };
  },
};
</script>
