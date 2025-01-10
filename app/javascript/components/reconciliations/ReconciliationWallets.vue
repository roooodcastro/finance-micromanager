<template>
  <BCard
    :title="t('sub_header_wallets')"
    no-body
  >
    <div class="table-responsive-md">
      <table class="table table-sm table-hover mb-0">
        <thead>
          <tr>
            <th class="bg-body-secondary align-middle text-nowrap">
              {{ t('table_header_wallet_name') }}
            </th>
            <th class="bg-body-secondary text-end text-nowrap d-none d-md-table-cell">
              {{ t('table_header_calculated_balance') }}

              <InfoTooltip :message="t('calculated_balance_info_text')" />
            </th>
            <th class="bg-body-secondary text-end text-nowrap">
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
              <div class="d-block d-md-none fw-bold">
                {{ formatMoney(walletBalances['']) }}
              </div>
            </td>
            <td class="text-end fw-bold bg-warning-subtle d-none d-md-table-cell">
              {{ formatMoney(walletBalances['']) }}
            </td>
            <td class="text-center bg-warning-subtle">
              <InfoTooltip :message="t('unspecified_balance_cannot_be_edited')" />
            </td>
          </tr>
        </tbody>

        <tfoot class="table-group-divider">
          <tr>
            <td class="text-nowrap fw-bold bg-body-secondary">
              {{ t('total') }}
              <div class="d-block d-md-none fw-bold">
                {{ formatMoney(walletBalancesSum) }}
              </div>
            </td>
            <td class="text-end fw-bold bg-body-secondary d-none d-md-table-cell">
              {{ formatMoney(walletBalancesSum) }}
            </td>
            <td class="text-end fw-bold bg-body-secondary">
              {{ formatMoney(realBalancesSum) }}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useWalletStore from '~/stores/WalletStore.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';

import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';
import ReconciliationWalletItem from '~/components/reconciliations/ReconciliationWalletItem.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    InfoTooltip,
    ReconciliationWalletItem,
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
