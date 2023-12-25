<template>
  <div class="btn-group d-flex bg-white flex-shrink-0 flex-grow-1 flex-lg-grow-0">
    <button
      class="btn btn-sm py-1 btn-outline-dark"
      :class="{ active: daysToShow === 7 }"
      @click="handleDateFilterClick(7)"
    >
      {{ t('seven_days') }}
    </button>

    <button
      class="btn btn-sm py-1 btn-outline-dark"
      :class="{ active: daysToShow === 30 }"
      @click="handleDateFilterClick(30)"
    >
      {{ t('thirty_days') }}
    </button>

    <button
      class="btn btn-sm btn-outline-dark"
      :class="{ active: daysToShow === 90 }"
      @click="handleDateFilterClick(90)"
    >
      {{ t('ninety_days') }}
    </button>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { setQueryParam } from '~/utils/QueryStringUtils.js';

export default {
  setup() {
    const transactionStore = useTransactionStore();

    const { daysToShow } = storeToRefs(transactionStore);

    const handleDateFilterClick = (numberOfDays) => {
      transactionStore.setFetchParams({ daysToShow: numberOfDays });
      setQueryParam('numberOfDays', numberOfDays || null);
      transactionStore.fetch();
    };

    return {
      daysToShow,
      handleDateFilterClick,
      t: I18n.scopedTranslator('views.transactions.filters'),
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionFilter__dropdown {
  width: 20rem;
}
</style>
