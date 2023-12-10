<template>
  <div class="d-flex justify-content-between flex-grow-1 flex-lg-grow-0">
    <div class="mb-3">
      <div class="dropdown">
        <a
          href="#"
          class="btn btn-sm btn-outline-dark rounded"
          data-bs-toggle="dropdown"
        >
          <FontAwesomeIcon icon="filter" />
          {{ t('filters') }}
        </a>

        <div
          class="dropdown-menu mt-1 px-3 pt-3 shadow-lg TransactionFilter__dropdown"
          @click="ev => ev.stopPropagation()"
        >
          <h6>{{ t('transaction_type') }}</h6>

          <div class="row justify-content-center">
            <div class="form-check form-switch col-6 d-flex justify-content-center">
              <input
                id="toggleIncludeDebits"
                class="form-check-input"
                type="checkbox"
                :checked="!excludeDebits"
                @change="handleToggleExcludeDebits"
              >
              <label
                class="form-check-label ms-2"
                for="toggleIncludeDebits"
              >
                {{ t('spends') }}
              </label>
            </div>

            <div class="form-check form-switch col-6 d-flex justify-content-center">
              <input
                id="toggleIncludeCredits"
                class="form-check-input"
                type="checkbox"
                :checked="!excludeCredits"
                @change="handleToggleExcludeCredits"
              >
              <label
                class="form-check-label ms-2"
                for="toggleIncludeCredits"
              >
                {{ t('income') }}
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="btn-group mb-3 d-flex bg-white ms-2">
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
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { setQueryParam } from '~/utils/QueryStringUtils.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  emits: ['change'],

  setup(_, { emit }) {
    const transactionStore = useTransactionStore();
    const { fetchParams, excludeDebits, excludeCredits, daysToShow } = storeToRefs(transactionStore);

    const handleToggleExcludeDebits = () => {
      transactionStore.setFetchParams({ excludeDebits: !fetchParams.value.excludeDebits });
      setQueryParam('excludeDebits', fetchParams.value.excludeDebits || null);
      emit('change');
    };

    const handleToggleExcludeCredits = () => {
      transactionStore.setFetchParams({ excludeCredits: !fetchParams.value.excludeCredits });
      setQueryParam('excludeCredits', fetchParams.value.excludeCredits || null);
      emit('change');
    };

    const handleDateFilterClick = (numberOfDays) => {
      transactionStore.setFetchParams({ daysToShow: numberOfDays });
      setQueryParam('numberOfDays', numberOfDays || null);
      emit('change');
    };

    return {
      excludeDebits,
      excludeCredits,
      daysToShow,
      handleToggleExcludeDebits,
      handleToggleExcludeCredits,
      handleDateFilterClick,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionFilter__dropdown {
  width: 20rem;
}
</style>
