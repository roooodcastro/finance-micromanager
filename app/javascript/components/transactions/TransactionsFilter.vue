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
          <h6>Transaction Type</h6>

          <div class="row justify-content-center">
            <div class="form-check form-switch col-6 d-flex justify-content-center">
              <input
                id="toggleIncludeDebits"
                class="form-check-input"
                type="checkbox"
                :checked="!excludeDebits"
                @change="handleToggleExcludeDebits"
              />
              <label
                class="form-check-label ms-2"
                for="toggleIncludeDebits"
              >
                Debits
              </label>
            </div>

            <div class="form-check form-switch col-6 d-flex justify-content-center">
              <input
                id="toggleIncludeCredits"
                class="form-check-input"
                type="checkbox"
                :checked="!excludeCredits"
                @change="handleToggleExcludeCredits"
              />
              <label
                class="form-check-label ms-2"
                for="toggleIncludeCredits"
              >
                Credits
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
        7 days
      </button>

      <button
        class="btn btn-sm py-1 btn-outline-dark"
        :class="{ active: daysToShow === 30 }"
        @click="handleDateFilterClick(30)"
      >
        30 days
      </button>

      <button
        class="btn btn-sm btn-outline-dark"
        :class="{ active: daysToShow === 90 }"
        @click="handleDateFilterClick(90)"
      >
        90 days
      </button>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { getQueryParams, setQueryParam } from '~/utils/QueryStringUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  emits: ['change'],

  setup(_, { emit }) {
    const transactionStore = useTransactionStore();
    const { daysToShow, excludeDebits, excludeCredits } = storeToRefs(transactionStore);

    excludeDebits.value = !!getQueryParams().excludeDebits;
    excludeCredits.value = !!getQueryParams().excludeCredits;

    const handleToggleExcludeDebits = () => {
      excludeDebits.value = !excludeDebits.value;
      setQueryParam('excludeDebits', excludeDebits.value || null);
      emit('change');
    };

    const handleToggleExcludeCredits = () => {
      excludeCredits.value = !excludeCredits.value;
      setQueryParam('excludeCredits', excludeCredits.value || null);
      emit('change');
    };

    const handleDateFilterClick = (numberOfDays) => {
      daysToShow.value = numberOfDays;
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
