<template>
  <div class="card">
    <div class="card-header">
      <h5 class="m-0 d-flex justify-content-between align-items-center">
        <span>
          {{ t('sub_header_balances') }}
        </span>
        <ReconciliationStatusBadge :reconciliation="reconciliation" />
      </h5>
    </div>
    <div class="card-body p-2 p-lg-3">
      <div class="ReconciliationSummary__balances d-flex align-items-center justify-content-evenly fs-5">
        <span class="text-center">
          {{ t('real_balance') }}
          <br>
          {{ formatMoney(realBalancesSum, reconciliation.currency.isoCode) }}
        </span>

        <FontAwesomeIcon
          icon="minus"
          :class="`mx-2 mx-md-3 text-${reconciliationVariant}`"
        />

        <span class="text-center">
          {{ t('calculated_balance') }}
          <br>
          {{ formatMoney(currentProfile.balanceAmount, reconciliation.currency.isoCode) }}
        </span>

        <FontAwesomeIcon
          icon="equals"
          :class="`mx-2 mx-md-3 text-${reconciliationVariant}`"
        />

        <span class="text-center">
          {{ t('difference_balance') }}
          <br>
          <span :class="{ 'text-credit': differenceSum > 0, 'text-debit': differenceSum < 0 }">
            {{ formatMoney(differenceSum, reconciliation.currency.isoCode) }}
          </span>
        </span>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import ReconciliationStatusBadge from '~/components/reconciliations/ReconciliationStatusBadge.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
    ReconciliationStatusBadge
  },

  setup() {
    const reconciliationStore = useReconciliationStore();
    const profileStore = useProfileStore();

    const { reconciliation, realBalancesSum } = storeToRefs(reconciliationStore);
    const { currentProfile } = storeToRefs(profileStore);

    const differenceSum = computed(() => realBalancesSum.value - currentProfile.value.balanceAmount);
    const reconciliationVariant = VARIANTS_FOR_RECONCILIATION_STATUSES[reconciliation.value.status];

    return {
      t: I18n.scopedTranslator('views.reconciliations.show'),
      formatMoney,
      reconciliation,
      currentProfile,
      realBalancesSum,
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
