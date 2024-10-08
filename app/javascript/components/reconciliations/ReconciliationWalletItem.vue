<template>
  <tr class="align-middle">
    <td class="text-nowrap">
      {{ wallet.name }}
      <div class="d-block d-md-none fw-bold">
        {{ formatMoney(walletBalance ?? 0) }}
      </div>
    </td>
    <td class="text-end fw-bold text-nowrap d-none d-md-table-cell">
      {{ formatMoney(walletBalance ?? 0) }}
    </td>
    <td>
      <div class="input-group input-group-sm flex-nowrap">
        <span
          class="input-group-text d-none d-md-inline-block"
        >
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
          class="ReconciliationWallets__input form-control form-control-sm text-end"
          type="number"
          :disabled="reconciliation.status !== 'in_progress' || loading"
          :value="reconciliationWallet?.balanceAmount"
          @change="handleChange"
        >
      </div>
    </td>
  </tr>
</template>

<script>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    wallet: {
      type: Object,
      required: true,
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
      return reconciliation.value.reconciliationsWallets.find(rw => rw.walletId === props.wallet.id);
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
      formatMoney,
      handleChange,
    }
  }
};
</script>

<style lang="scss" scoped>
.ReconciliationWallets__input {
  -moz-appearance:textfield;
  min-width: 7rem;

}

.ReconciliationWallets__input::-webkit-outer-spin-button, .ReconciliationWallets__input::-webkit-inner-spin-button {
  -webkit-appearance: none;
}
</style>
