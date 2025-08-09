<template>
  <div>
    <div
      v-if="showSearch"
      class="mb-3"
    >
      <SearchField
        id="transactionSearch"
        v-model="fetchParams.searchString"
        name="transactionSearch"
        :placeholder="t('search_label')"
        @input="handleSearchInput"
      />
    </div>
    <div class="dropdown d-flex gap-3 flex-wrap flex-lg-nowrap">
      <MultipleSelect
        v-model="selectedCategoryIds"
        class="flex-grow-1 flex-lg-grow-0"
        select-class="minimalist-secondary-select"
        :options="categoriesForSelect(true)"
        :placeholder="t('category_filter')"
        :selection-label-one="t('category')"
        :selection-label-many="t('categories')"
        @change="handleCategoryChange"
      />

      <MultipleSelect
        v-model="selectedWalletIds"
        class="flex-grow-1 flex-lg-grow-0"
        select-class="minimalist-secondary-select"
        :options="walletsForSelect"
        :placeholder="t('wallet_filter')"
        :selection-label-one="t('wallet')"
        :selection-label-many="t('wallets')"
        @change="handleWalletChange"
      />

      <select
        class="minimalist-secondary-select flex-grow-1 flex-lg-grow-0 bg-body"
        :value="transactionTypeValue"
        @change="handleTransactionTypeChange"
      >
        <option value="0">
          {{ t('all_transaction_types') }}
        </option>
        <option value="-1">
          {{ t('only_spends') }}
        </option>
        <option value="1">
          {{ t('only_income') }}
        </option>
      </select>

      <div
        v-if="showDateRange"
        class="TransactionsFilter__date-range btn-group d-flex flex-shrink-0 flex-grow-1 flex-lg-grow-0 bg-body"
      >
        <button
          class="btn btn-sm btn-outline-secondary"
          :class="{ active: daysToShow.toString() === '7' }"
          @click="handleDateFilterClick(7)"
        >
          {{ t('seven_days') }}
        </button>

        <button
          class="btn btn-sm btn-outline-secondary"
          :class="{ active: daysToShow.toString() === '30' }"
          @click="handleDateFilterClick(30)"
        >
          {{ t('thirty_days') }}
        </button>

        <button
          class="btn btn-sm btn-outline-secondary"
          :class="{ active: daysToShow.toString() === '90' }"
          @click="handleDateFilterClick(90)"
        >
          {{ t('ninety_days') }}
        </button>

        <button
          class="btn btn-sm btn-outline-secondary"
          :class="{ active: daysToShow.toString() === '0' }"
          @click="handleDateFilterClick(0)"
        >
          {{ t('all_days') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { setQueryParam } from '~/utils/QueryStringUtils.js';

import MultipleSelect from '~/components/forms/MultipleSelect.vue';
import SearchField from '~/components/ui/SearchField.vue';

export default {
  components: {
    MultipleSelect,
    SearchField,
  },

  props: {
    showDateRange: {
      type: Boolean,
      default: false,
    },
    showSearch: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const transactionStore = useTransactionStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const { fetchParams, daysToShow } = storeToRefs(transactionStore);
    const { categories, categoriesForSelect } = storeToRefs(categoryStore);
    const { activeWallets, walletsForSelect } = storeToRefs(walletStore);

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const transactionTypeValue = computed(() => {
      if (fetchParams.value.excludeCredits) {
        return '-1';
      } else if (fetchParams.value.excludeDebits) {
        return '1';
      } else {
        return '0';
      }
    });

    const handleDateFilterClick = (numberOfDays) => {
      if (fetchParams.value.daysToShow !== numberOfDays) {
        transactionStore.setFetchParams({ daysToShow: numberOfDays });
        setQueryParam('days_to_show', numberOfDays ?? null);
        transactionStore.fetchCollection();
      }
    };

    const handleTransactionTypeChange = (ev) => {
      let excludeDebits = false;
      let excludeCredits = false;

      const option = parseInt(ev.target.value);

      if (option === -1) {
        excludeCredits = true;
      } else if (option === 1) {
        excludeDebits = true;
      }

      transactionStore.setFetchParams({ excludeDebits, excludeCredits });
      setQueryParam('exclude_credits', fetchParams.value.excludeCredits || null);
      setQueryParam('exclude_debits', fetchParams.value.excludeDebits || null);
      transactionStore.fetchCollection();
    };

    const handleCategoryChange = () => {
      transactionStore.setFetchParams({ categoryIds: selectedCategoryIds.value });
      setQueryParam('category_ids', selectedCategoryIds.value.length ? selectedCategoryIds.value : null);
      transactionStore.fetchCollection();
    };

    const handleWalletChange = () => {
      transactionStore.setFetchParams({ walletIds: selectedWalletIds.value });
      setQueryParam('wallet_ids', selectedWalletIds.value.length ? selectedWalletIds.value : null);
      transactionStore.fetchCollection();
    };

    const handleSearchInput = () => {
      setQueryParam('search_string', fetchParams.value.searchString || null);
      transactionStore.fetchCollection();
    };

    const selectedCategoryIds = ref(fetchParams.value.categoryIds);
    const selectedWalletIds = ref(fetchParams.value.walletIds);

    return {
      selectedCategoryIds,
      selectedWalletIds,
      categoriesForSelect,
      walletsForSelect,
      daysToShow,
      fetchParams,
      transactionTypeValue,
      handleCategoryChange,
      handleWalletChange,
      handleDateFilterClick,
      handleTransactionTypeChange,
      handleSearchInput,
      t: I18n.scopedTranslator('views.transactions.filters'),
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionsFilter__date-range {
  height: fit-content;
}
</style>
