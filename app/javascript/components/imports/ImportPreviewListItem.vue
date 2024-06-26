<template>
  <tr
    :class="`table-${importActionVariants[transaction.actionId]} side-strip side-strip-${importActionVariants[transaction.actionId]}`"
  >
    <td class="align-middle ps-3">
      <input
        :value="transaction.name"
        class="form-control"
        required
        @change="handleNameChange(transaction.id, $event)"
      >
    </td>

    <td
      class="width-12rem align-middle text-end"
      :class="{ 'text-debit': isSpend, 'text-credit': isIncome }"
    >
      {{ formatMoney(transaction.amount) }}
    </td>

    <td class="width-10rem align-middle">
      <input
        :value="transaction.transactionDate"
        class="form-control px-3"
        type="date"
        required
        @change="handleDateChange(transaction.id, $event)"
      >
    </td>

    <td class="align-middle">
      <CategoriesSelect
        :value="transaction.categoryId"
        :placeholder="t('category_placeholder')"
        required
        @change="handleCategoryChange(transaction.id, $event)"
      />
    </td>

    <td class="align-middle">
      <ImportActionsSelect
        :value="transaction.actionId"
        required
        @change="handleActionChange(transaction.id, $event)"
      />
    </td>
  </tr>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useImportStore from '~/stores/ImportStore.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { VARIANTS_FOR_IMPORT_ACTIONS } from '~/utils/Constants.js';

import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import ImportActionsSelect from '~/components/imports/ImportActionsSelect.vue';

export default {
  components: {
    CategoriesSelect,
    ImportActionsSelect,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');

    const importStore = useImportStore();
    const profileStore = useProfileStore();
    const categoryStore = useCategoryStore();

    const { currentProfile } = storeToRefs(profileStore);
    const { categories } = storeToRefs(categoryStore);

    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);
    const isSpend = computed(() => props.transaction.amount < 0);
    const isIncome = computed(() => props.transaction.amount > 0);
    const categoryNameFor = categoryStore.categoryNameFor;

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    const handleNameChange = (transactionId, event) => {
      importStore.updatePreviewData(transactionId, { name: event.target.value });
    };

    const handleDateChange = (transactionId, event) => {
      importStore.updatePreviewData(transactionId, { transactionDate: event.target.value });
    };

    const handleCategoryChange = (transactionId, categoryId) => {
      importStore.updatePreviewData(transactionId, { categoryId });
    };

    const handleActionChange = (transactionId, actionId) => {
      importStore.updatePreviewData(transactionId, { actionId });
    };

    return {
      t,
      currencySymbol,
      isSpend,
      isIncome,
      categoryNameFor,
      importActionVariants: VARIANTS_FOR_IMPORT_ACTIONS,
      formatDate,
      formatMoney,
      handleActionChange,
      handleCategoryChange,
      handleNameChange,
      handleDateChange,
    };
  },
};
</script>
