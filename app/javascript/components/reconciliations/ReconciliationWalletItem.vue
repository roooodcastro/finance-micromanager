<template>
  <div
    class="ReconciliationWalletItem__walletsListItem d-grid p-2 py-3 px-lg-3 gap-2 border-bottom"
    :class="{ 'bg-warning-subtle': !wallet }"
  >
    <div class="text-ReconciliationWalletItem__walletName">
      {{ wallet?.name ?? t('unspecified') }}
    </div>

    <div class="ReconciliationWalletItem__walletBalance text-start text-lg-end">
      <span class="d-inline d-lg-none">
        {{ t('calculated_balance') }}:
      </span>
      <span class="fw-bold">
        {{ formatMoney(walletBalance ?? 0) }}
      </span>
    </div>

    <div class="ReconciliationWalletItem__diff text-end">
      <span
        v-if="balanceDiff !== null"
        class="d-inline d-lg-none"
      >
        {{ t('difference_sm_balance') }}:
      </span>
      <span
        v-if="balanceDiff !== null"
        class="fw-bold"
        :class="{ 'text-credit': balanceDiff > 0, 'text-debit': balanceDiff < 0 }"
      >
        {{ formatMoney(balanceDiff) }}
      </span>
    </div>

    <div
      v-if="wallet"
      class="ReconciliationWalletItem__realInput input-group input-group-sm flex-nowrap"
    >
      <span class="input-group-text">
        <FontAwesomeIcon
          v-if="loading"
          icon="spinner"
          spin
        />
        <FontAwesomeIcon
          v-else-if="saved"
          icon="check"
          class="text-success"
        />
        <template v-else>
          {{ wallet.currency.symbol }}
        </template>
      </span>
      <input
        class="ReconciliationWalletItem__input form-control form-control-sm text-end"
        type="number"
        :disabled="reconciliation.status !== 'in_progress' || loading"
        :value="reconciliationWallet?.balanceAmount"
        :placeholder="t('real_balance')"
        @change="handleChange"
      >
    </div>
    <div
      v-else
      class="ReconciliationWalletItem__realInput text-center"
    >
      <InfoTooltip :message="t('unspecified_balance_cannot_be_edited')" />
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';

export default {
  components: {
    FontAwesomeIcon,
    InfoTooltip,
  },

  props: {
    wallet: {
      type: Object,
      default: null,
    },
    walletBalance: {
      type: Number,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.reconciliations.show');

    const loading = ref(false);
    const saved = ref(false);
    const timeout = ref(null);

    const reconciliationStore = useReconciliationStore();
    const reconciliationWalletStore = useReconciliationWalletStore();

    const { reconciliation } = storeToRefs(reconciliationStore);

    const reconciliationWallet = computed(() => {
      return reconciliation.value.reconciliationsWallets.find(rw => rw.walletId === props.wallet?.id);
    });
    const balanceDiff = computed(() => {
      if (reconciliationWallet.value) {
        return (reconciliationWallet.value.balanceAmount ?? 0) - (props.walletBalance ?? 0);
      } else {
        return null;
      }
    });

    const handleChange = (ev) => {
      const balanceAmount = ev.target.value;
      const reconciliationWalletId = reconciliationWallet.value?.id;
      loading.value = true;
      saved.value = false;
      clearTimeout(timeout.value);

      reconciliationWalletStore
        .create(reconciliationWalletId, {
          reconciliationId: reconciliation.id,
          walletId: props.wallet.id,
          balanceAmount
        })
        .then(() => {
          saved.value = true;
          timeout.value = setTimeout(() => saved.value = false, 5000);
        })
        .catch(() => {})
        .finally(() => loading.value = false);
    };

    return {
      t,
      loading,
      saved,
      reconciliation,
      reconciliationWallet,
      balanceDiff,
      formatMoney,
      handleChange,
    }
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ReconciliationWalletItem__input {
  appearance: textfield;
  -moz-appearance: textfield;
  min-width: 7rem;

}

.ReconciliationWalletItem__input::-webkit-outer-spin-button, .ReconciliationWalletItem__input::-webkit-inner-spin-button {
  -webkit-appearance: none;
}

.ReconciliationWalletItem__walletsListItem {
  grid-template-columns: minmax(0, 1fr) minmax(6rem, 1fr) minmax(6rem, 1fr) minmax(8rem, 1fr);
  align-items: center;
}

.ReconciliationWalletItem__walletName {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

@include media-breakpoint-down(lg) {
  .ReconciliationWalletItem__walletsListItem {
    grid-template-columns: minmax(0, 1fr) minmax(8rem, 1fr);
  }

  .ReconciliationWalletItem__walletName {
    order: 1;
  }

  .ReconciliationWalletItem__walletBalance {
    order: 3;
    font-size: $h6-font-size;
  }

  .ReconciliationWalletItem__diff {
    order: 4;
    font-size: $h6-font-size;
  }

  .ReconciliationWalletItem__realInput {
    order: 2;
  }
}
</style>
