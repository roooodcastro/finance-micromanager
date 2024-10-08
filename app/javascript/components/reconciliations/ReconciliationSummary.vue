<template>
  <BCard
    :title="t('sub_header_balances')"
    no-body
  >
    <template v-slot:header>
      <ReconciliationStatusBadge :reconciliation="reconciliation" />
    </template>

    <div class="card-body p-2 p-lg-3">
      <div class="ReconciliationSummary__balances d-flex align-items-center justify-content-evenly fs-5">
        <span class="text-center">
          {{ t('real_balance') }}
          <br>
          {{ formatMoney(realBalancesSum) }}
        </span>

        <FontAwesomeIcon
          icon="minus"
          :class="`mx-2 mx-md-3 text-${reconciliationVariant}`"
        />

        <span class="text-center">
          {{ t('calculated_balance') }}
          <br>
          {{ formatMoney(walletBalancesSum) }}
        </span>

        <FontAwesomeIcon
          icon="equals"
          :class="`mx-2 mx-md-3 text-${reconciliationVariant}`"
        />

        <span class="text-center">
          {{ t('difference_balance') }}
          <br>
          <span :class="{ 'text-credit': differenceSum > 0, 'text-debit': differenceSum < 0 }">
            {{ formatMoney(differenceSum) }}
          </span>
        </span>
      </div>
    </div>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import ReconciliationStatusBadge from '~/components/reconciliations/ReconciliationStatusBadge.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    FontAwesomeIcon,
    ReconciliationStatusBadge
  },

  setup() {
    const reconciliationStore = useReconciliationStore();

    const { reconciliation, realBalancesSum, walletBalancesSum } = storeToRefs(reconciliationStore);

    const differenceSum = computed(() => realBalancesSum.value - walletBalancesSum.value);
    const reconciliationVariant = computed(() => {
      return VARIANTS_FOR_RECONCILIATION_STATUSES[reconciliation.value.status];
    });

    return {
      t: I18n.scopedTranslator('views.reconciliations.show'),
      formatMoney,
      reconciliation,
      realBalancesSum,
      walletBalancesSum,
      differenceSum,
      reconciliationVariant,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ReconciliationSummary__card-body {
  grid-template-columns: repeat(2, minmax(0, 1fr));
  grid-auto-flow: column;
}

@include media-breakpoint-up(md) {
  .ReconciliationSummary__balances {
    font-size: 1.5rem !important;
  }
}

</style>
