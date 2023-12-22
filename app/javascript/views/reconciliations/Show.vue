<template>
  <PageHeader
    :title="t('title', { date: formatDate(reconciliationFromStore.date) })"
    :back-button-href="reconciliationsPath"
    class="flex-wrap"
  />

  <div class="row">
    <div class="col-12 col-lg-6">
      <ReconciliationSummary />
      <ReconciliationWallets class="mt-3" />
    </div>

    <div class="col-12 col-lg-6 mt-3 mt-lg-0">
      <div class="card">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_transactions') }}
          </h5>
        </div>
        <div class="card-body p-0">
          <TransactionsList
            :transactions="transactions"
            compact
            card-body
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import dayjs from 'dayjs';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ReconciliationSummary from '~/components/reconciliations/ReconciliationSummary.vue';
import ReconciliationWallets from '~/components/reconciliations/ReconciliationWallets.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    PageHeader,
    ReconciliationSummary,
    ReconciliationWallets,
    TransactionsList,
  },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
    walletBalances: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const reconciliationsPath = reconciliationsApi.index.path();

    const reconciliationWalletStore = useReconciliationWalletStore();
    reconciliationWalletStore.setReconciliationId(props.reconciliation.id);

    // Load reconciliations from props
    const reconciliationStore = useReconciliationStore();
    const { reconciliation: reconciliationFromStore, walletBalances } = storeToRefs(reconciliationStore);
    reconciliationFromStore.value = props.reconciliation;
    walletBalances.value = props.walletBalances;

    const transactionStore = useTransactionStore();
    const profileStore = useProfileStore();

    const { currentProfile } = storeToRefs(profileStore);
    const startDate = currentProfile.lastReconciliationDate ?? dayjs(0);

    transactionStore.setFetchParams({
      updateDateRange: false,
      startDate: dayjs(startDate).add(1, 'day'),
      endDate: props.reconciliation.date,
      daysToShow: 0,
    });
    transactionStore.fetch();
    const { transactions } = storeToRefs(transactionStore);

    return {
      t: I18n.scopedTranslator('views.reconciliations.show'),
      formatDate,
      transactions,
      reconciliationsPath,
      reconciliationFromStore,
    };
  },
};
</script>
