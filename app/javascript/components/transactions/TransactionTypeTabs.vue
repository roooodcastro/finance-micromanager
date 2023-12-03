<template>
  <ul class="nav nav-tabs card-header-tabs row text-center">
    <li class="col-4 nav-item active me-0 p-0">
      <a
        class="TransactionTypeTabs__link nav-link link-body-emphasis"
        :class="{ 'active': !(excludeDebits || excludeCredits) }"
        href="#"
        @click="handleTabChange(ALL_TRANSACTIONS)"
      >
        {{ t('all_transactions') }}
      </a>
    </li>
    <li class="col-4 nav-item me-0 p-0">
      <a
        class="TransactionTypeTabs__link nav-link link-body-emphasis"
        :class="{ 'active': excludeCredits }"
        href="#"
        @click="handleTabChange(DEBIT_TRANSACTION)"
      >
        {{ t('debit_transactions') }}
      </a>
    </li>
    <li class="col-4 nav-item me-0 p-0">
      <a
        class="TransactionTypeTabs__link nav-link link-body-emphasis"
        :class="{ 'active': excludeDebits }"
        href="#"
        @click="handleTabChange(CREDIT_TRANSACTION)"
      >
        {{ t('credit_transactions') }}
      </a>
    </li>
  </ul>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { DEBIT_TRANSACTION, CREDIT_TRANSACTION, ALL_TRANSACTIONS } from '~/utils/Constants.js';

export default {
  props: {
    transactionsToShow: {
      type: Number,
      default: null,
    },
  },

  setup(props) {
    const dateRangeStore = useDateRangeStore();
    const transactionStore = useTransactionStore();


    const { excludeDebits, excludeCredits } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);

    const handleTabChange = (newType) => {
      transactionStore.setTransactionType(newType);

      transactionStore.fetch({
        startDate: startDate.value,
        endDate: endDate.value,
        items: props.transactionsToShow,
        daysToShow: 0,
      });
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

.TransactionTypeTabs__link:hover {
  background-color: $gray-300;
}
</style>
