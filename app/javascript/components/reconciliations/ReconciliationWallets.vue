<template>
  <BCard
    no-body
    class="ReconciliationWallets__cardBody"
  >
    <template v-slot:header>
      <h4 class="card-title m-0 d-flex gap-3 align-items-center justify-content-between flex-grow-1">
        {{ t('sub_header_wallets') }}
        <HelpButton @click="openHelpModal" />
      </h4>
    </template>

    <div class="ReconciliationWallets__header d-none d-lg-grid  p-2 py-3 px-lg-3 gap-2 border-bottom bg-body-secondary fw-bold">
      <div>
        {{ t('table_header_wallet_name') }}
      </div>
      <div class="text-end">
        {{ t('table_header_calculated_balance') }}

        <InfoTooltip :message="t('calculated_balance_info_text')" />
      </div>
      <div class="text-end">
        {{ t('difference_balance') }}

        <InfoTooltip :message="t('divergence_info_text')" />
      </div>
      <div class="text-end">
        {{ t('table_header_real_balance') }}

        <InfoTooltip :message="t('real_balance_info_text')" />
      </div>
    </div>

    <ReconciliationWalletItem
      v-for="wallet in wallets"
      :key="wallet.id"
      :wallet-balance="walletBalances[wallet.id]"
      :wallet="wallet"
    />

    <ReconciliationWalletItem
      v-if="walletBalances['']"
      :wallet-balance="walletBalances['']"
    />

    <HelpModal
      :title="t('reconciliation_wallets_help_title')"
      :message="t('reconciliation_wallets_help_message')"
    />
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useWalletStore from '~/stores/WalletStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import { HELP_MODAL_ID } from '~/utils/Constants.js';

import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';
import ReconciliationWalletItem from '~/components/reconciliations/ReconciliationWalletItem.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import HelpButton from '~/components/ui/HelpButton.vue';
import HelpModal from '~/components/ui/HelpModal.vue';

export default {
  components: {
    BCard,
    HelpButton,
    InfoTooltip,
    ReconciliationWalletItem,
    HelpModal,
  },

  setup() {
    const t = I18n.scopedTranslator('views.reconciliations.show');

    const walletStore = useWalletStore();
    const modalStore = useModalStore();
    const reconciliationStore = useReconciliationStore();

    walletStore.fetchCollection();

    const { activeWallets: wallets } = storeToRefs(walletStore);
    const { realBalancesSum, walletBalances, walletBalancesSum } = storeToRefs(reconciliationStore);

    const openHelpModal = () => modalStore.show(HELP_MODAL_ID);

    return {
      t,
      wallets,
      realBalancesSum,
      walletBalances,
      walletBalancesSum,
      formatMoney,
      openHelpModal,
    }
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ReconciliationWallets__header {
  grid-template-columns: minmax(0, 1fr) minmax(6rem, 1fr) minmax(6rem, 1fr) minmax(8rem, 1fr);
}

.ReconciliationWallets__cardBody .BCard__no-body > div:last-child {
  border-bottom: none !important;
  border-radius: 0 0 $border-radius $border-radius;
}
</style>
