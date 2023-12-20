<template>
  <div class="card overflow-hidden">
    <div class="card-header">
      <h5 class="m-0">
        {{ t('sub_header_wallets') }}
      </h5>
    </div>
    <div class="card-body table-responsive-md p-0">
      <table class="table table-sm table-hover mb-0">
        <thead>
          <tr>
            <th
              class="bg-light align-middle"
              style="width: 50%"
            >
              {{ t('table_header_wallet_name') }}
            </th>
            <th
              class="bg-light text-end text-nowrap"
              style="width: 25%"
            >
              {{ t('table_header_calculated_balance') }}

              <InfoTooltip :message="t('calculated_balance_info_text')" />
            </th>
            <th
              class="bg-light text-end text-nowrap"
              style="width: 25%"
            >
              {{ t('table_header_real_balance') }}

              <InfoTooltip :message="t('real_balance_info_text')" />
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="wallet in wallets"
            :key="wallet.id"
            class="align-middle"
          >
            <td class="text-nowrap">
              {{ wallet.name }}
            </td>
            <td class="text-end fw-bold">
              {{ wallet.balanceFormatted }}
            </td>
            <td>
              <div class="input-group input-group-sm flex-nowrap">
                <span
                  class="input-group-text d-none d-md-inline-block"
                >
                  <FontAwesomeIcon
                    v-if="loading[wallet.id]"
                    icon="spinner"
                    spin
                  />
                  <FontAwesomeIcon
                    v-else-if="saved[wallet.id]"
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
                  :value="groupedReconciliationsWallets[wallet.id]?.balanceAmount ?? wallet.balance"
                  @change="handleChange($event, wallet.id)"
                >
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
    InfoTooltip,
  },

  setup() {
    const t = I18n.scopedTranslator('views.reconciliations.show');

    const loading = ref({});
    const saved = ref({});
    const timeouts = ref({});

    const walletStore = useWalletStore();
    const reconciliationStore = useReconciliationStore();
    const reconciliationWalletStore = useReconciliationWalletStore();

    walletStore.fetch();

    const { activeWallets: wallets } = storeToRefs(walletStore);
    const { reconciliation } = storeToRefs(reconciliationStore);

    const groupedReconciliationsWallets = computed(() => {
      return _.keyBy(reconciliation.value.reconciliationsWallets, 'walletId');
    });

    const handleChange = (ev ,walletId) => {
      const balanceAmount = ev.target.value;
      const reconciliationWalletId = groupedReconciliationsWallets.value[walletId]?.id;
      loading.value[walletId] = true;
      saved.value[walletId] = false;
      clearTimeout(timeouts.value[walletId]);

      reconciliationWalletStore
        .create(reconciliationWalletId, { reconciliationId: reconciliation.id, walletId, balanceAmount })
        .then(() => {
        loading.value[walletId] = false;
        saved.value[walletId] = true;
        timeouts.value[walletId] = setTimeout(() => saved.value[walletId] = false, 5000);
      });
    };

    return {
      t,
      loading,
      saved,
      wallets,
      handleChange,
      groupedReconciliationsWallets,
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
