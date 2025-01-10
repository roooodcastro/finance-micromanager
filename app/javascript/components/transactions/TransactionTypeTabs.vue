<template>
  <div class="TransactionTypeTabs p-2 rounded">
    <ul class="nav nav-pills row text-center mx-0">
      <li class="col-4 nav-item active me-0 p-0">
        <a
          class="TransactionTypeTabs__link nav-link"
          :class="{ 'active': !(excludeDebits || excludeCredits) }"
          href="#"
          @click="handleTabChange(ALL_TRANSACTIONS)"
        >
          {{ t('all_transactions') }}
        </a>
      </li>
      <li class="col-4 nav-item me-0 p-0">
        <a
          class="TransactionTypeTabs__link nav-link"
          :class="{ 'active': excludeCredits }"
          href="#"
          @click="handleTabChange(DEBIT_TRANSACTION)"
        >
          {{ t('debit_transactions') }}
        </a>
      </li>
      <li class="col-4 nav-item me-0 p-0">
        <a
          class="TransactionTypeTabs__link nav-link"
          :class="{ 'active': excludeDebits }"
          href="#"
          @click="handleTabChange(CREDIT_TRANSACTION)"
        >
          {{ t('credit_transactions') }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import { DEBIT_TRANSACTION, CREDIT_TRANSACTION, ALL_TRANSACTIONS } from '~/utils/Constants.js';

export default {
  setup() {
    const transactionStore = useTransactionStore();
    const paginationStore = usePaginationStore();

    const { excludeDebits, excludeCredits } = storeToRefs(transactionStore);

    const handleTabChange = (newType) => {
      transactionStore.setTransactionType(newType);
      paginationStore.setPage(1);
      transactionStore.fetchCollection();
    };

    return {
      t: I18n.scopedTranslator('views.transactions.types'),
      excludeDebits,
      excludeCredits,
      handleTabChange,
      DEBIT_TRANSACTION,
      CREDIT_TRANSACTION,
      ALL_TRANSACTIONS,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.TransactionTypeTabs {
  background-color: var(--bs-tertiary-bg);
}
</style>
