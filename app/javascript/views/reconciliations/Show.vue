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
      <div
        v-if="reconciliationFromStore.status === 'in_progress'"
        class="card mb-3"
      >
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="m-0 ">
            {{ t('sub_header_actions') }}
          </h5>
        </div>
        <div class="card-body d-flex gap-2 justify-content-evenly">
          <ReconciliationActions
            :reconciliation="reconciliationFromStore"
            buttons
            show-finish
          />
        </div>
      </div>

      <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="m-0 ">
            {{ t('sub_header_transactions') }}
            <span class="fs-6 d-block mt-2">
              {{ transactionPeriodMessage }}
            </span>
          </h5>

          <div class="d-flex">
            <TransactionsFilter
              hide-toggle-text
              toggle-classes="btn btn-context-action rounded-circle"
            />

            <DropdownMenu
              toggle-icon="gear"
              :toggle-label="t('subcategories_options')"
              class="ms-1"
            >
              <DropdownMenuItem
                :label="t('new_transaction')"
                icon="plus"
                @click="handleNewTransaction"
              />

              <DropdownMenuItem
                v-if="!massEditMode"
                :label="t('enter_mass_edit_transactions')"
                icon="pen-to-square"
                @click="handleEnterMassEditTransactions"
              />

              <DropdownMenuItem
                v-else
                :label="t('cancel_mass_edit_transactions')"
                icon="xmark"
                @click="handleCancelMassEditTransactions"
              />
            </DropdownMenu>
          </div>
        </div>
        <div class="card-body p-0">
          <TransactionsList
            :transactions="transactions"
            compact
            card-body
            class="mb-3"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';
import dayjs from 'dayjs';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useReconciliationWalletStore from '~/stores/ReconciliationWalletStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ReconciliationSummary from '~/components/reconciliations/ReconciliationSummary.vue';
import ReconciliationWallets from '~/components/reconciliations/ReconciliationWallets.vue';
import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import ReconciliationActions from '~/components/reconciliations/ReconciliationActions.vue';

export default {
  components: {
    ReconciliationActions,
    DropdownMenuItem,
    DropdownMenu,
    PageHeader,
    ReconciliationSummary,
    ReconciliationWallets,
    TransactionsFilter,
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
    const t = I18n.scopedTranslator('views.reconciliations.show');

    const reconciliationsPath = reconciliationsApi.index.path();

    const transactionStore = useTransactionStore();
    const reconciliationStore = useReconciliationStore();
    const reconciliationWalletStore = useReconciliationWalletStore();

    reconciliationWalletStore.setReconciliationId(props.reconciliation.id);
    const { reconciliation: reconciliationFromStore, walletBalances } = storeToRefs(reconciliationStore);
    reconciliationFromStore.value = props.reconciliation;
    walletBalances.value = props.walletBalances;

    const startDate = dayjs.tz(reconciliationFromStore.value.previousReconciliationDate ?? 0, 'utc')
      .add(1, 'day');

    transactionStore.setFetchParams({
      updateDateRange: false,
      startDate,
      endDate: props.reconciliation.date,
      daysToShow: 0,
    });
    transactionStore.fetch();
    const { transactions, massEditMode, defaultTransactionDate } = storeToRefs(transactionStore);

    // Change default transaction date for new transactions created on this page
    defaultTransactionDate.value = props.reconciliation.date;

    const transactionPeriodMessage = t('sub_sub_header_transactions', {
      start_date: formatDate(startDate),
      end_date: formatDate(reconciliationFromStore.value.date),
    });

    watch(transactions, () => reconciliationStore.fetchSingle());

    const handleNewTransaction = () => transactionStore.openFormModal(null);
    const handleEnterMassEditTransactions = transactionStore.enterMassEditMode;
    const handleCancelMassEditTransactions = transactionStore.cancelMassEditMode;

    return {
      t,
      formatDate,
      transactions,
      massEditMode,
      reconciliationsPath,
      reconciliationFromStore,
      transactionPeriodMessage,
      handleNewTransaction,
      handleEnterMassEditTransactions,
      handleCancelMassEditTransactions,
    };
  },
};
</script>
