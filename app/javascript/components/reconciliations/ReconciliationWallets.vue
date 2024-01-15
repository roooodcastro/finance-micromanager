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
              class="bg-light align-middle text-nowrap"
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
          <ReconciliationWalletItem
            v-for="wallet in wallets"
            :key="wallet.id"
            :wallet-balance="walletBalances[wallet.id]"
            :wallet="wallet"
          />

          <tr
            v-if="walletBalances['']"
          >
            <td class="text-nowrap bg-warning-subtle">
              {{ t('unspecified') }}
            </td>
            <td class="text-end fw-bold bg-warning-subtle">
              {{ formatMoney(walletBalances['']) }}
            </td>
            <td class="text-center bg-warning-subtle">
              <InfoTooltip :message="t('unspecified_balance_cannot_be_edited')" />
            </td>
          </tr>
        </tbody>

        <tfoot class="table-group-divider">
          <tr>
            <td class="text-nowrap fw-bold bg-light">
              {{ t('total') }}
            </td>
            <td class="text-end fw-bold bg-light">
              {{ formatMoney(walletBalancesSum) }}
            </td>
            <td class="text-end fw-bold bg-light">
              {{ formatMoney(realBalancesSum) }}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useWalletStore from '~/stores/WalletStore.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';

import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';
import ReconciliationWalletItem from '~/components/reconciliations/ReconciliationWalletItem.vue';

export default {
  components: {
    ReconciliationWalletItem,
    InfoTooltip,
  },

  setup() {
    const t = I18n.scopedTranslator('views.reconciliations.show');

    const walletStore = useWalletStore();
    const reconciliationStore = useReconciliationStore();

    walletStore.fetchCollection();

    const { activeWallets: wallets } = storeToRefs(walletStore);
    const { realBalancesSum, walletBalances, walletBalancesSum } = storeToRefs(reconciliationStore);

    return {
      t,
      wallets,
      realBalancesSum,
      walletBalances,
      walletBalancesSum,
      formatMoney,
    }
  }
};
</script>
