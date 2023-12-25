<template>
  <div class="dropdown flex-shrink-0">
    <a
      href="#"
      class="w-100"
      :class="{ 'btn btn-sm btn-outline-dark': !linkToggle, 'text-dark text-decoration-none': linkToggle }"
      data-bs-toggle="dropdown"
    >
      <FontAwesomeIcon icon="filter" />
      <span
        class="ms-2"
        :class="{ 'd-none d-lg-inline': linkToggle }"
      >
        {{ t('filters') }}
      </span>
    </a>

    <div
      class="dropdown-menu mt-1 px-3 pt-3 shadow-lg TransactionFilter__dropdown"
      @click="ev => ev.stopPropagation()"
    >
      <h6>{{ t('category') }}</h6>

      <MultipleSelect
        v-model="selectedCategoryIds"
        class="flex-grow-1 flex-lg-grow-0 width-15rem w-100 mb-3"
        :options="categoriesForSelect"
        :placeholder="t('category_filter')"
        :selection-label-one="t('category')"
        :selection-label-many="t('categories')"
        @change="handleCategoryChange"
      />

      <h6>{{ t('wallet') }}</h6>

      <MultipleSelect
        v-model="selectedWalletIds"
        class="flex-grow-1 flex-lg-grow-0 width-15rem w-100 mb-3"
        :options="walletsForSelect"
        :placeholder="t('wallet_filter')"
        :selection-label-one="t('wallet')"
        :selection-label-many="t('wallets')"
        @change="handleWalletChange"
      />

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
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { setQueryParam } from '~/utils/QueryStringUtils.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import MultipleSelect from '~/components/forms/MultipleSelect.vue';

export default {
  components: {
    FontAwesomeIcon,
    MultipleSelect,
  },

  props: {
    linkToggle: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const transactionStore = useTransactionStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const { fetchParams, excludeDebits, excludeCredits } = storeToRefs(transactionStore);
    const { categoriesForSelect } = storeToRefs(categoryStore);
    const { walletsForSelect } = storeToRefs(walletStore);

    const handleToggleExcludeDebits = () => {
      transactionStore.setFetchParams({ excludeDebits: !fetchParams.value.excludeDebits });
      setQueryParam('excludeDebits', fetchParams.value.excludeDebits || null);
      transactionStore.fetch();
    };

    const handleToggleExcludeCredits = () => {
      transactionStore.setFetchParams({ excludeCredits: !fetchParams.value.excludeCredits });
      setQueryParam('excludeCredits', fetchParams.value.excludeCredits || null);
      transactionStore.fetch();
    };

    const handleCategoryChange = () => {
      transactionStore.setFetchParams({ categoryIds: selectedCategoryIds.value });
      transactionStore.fetch();
    };

    const handleWalletChange = () => {
      transactionStore.setFetchParams({ walletIds: selectedWalletIds.value });
      transactionStore.fetch();
    };

    const selectedCategoryIds = ref('');
    const selectedWalletIds = ref('');

    return {
      selectedCategoryIds,
      selectedWalletIds,
      excludeDebits,
      excludeCredits,
      categoriesForSelect,
      walletsForSelect,
      handleToggleExcludeDebits,
      handleToggleExcludeCredits,
      handleCategoryChange,
      handleWalletChange,
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
