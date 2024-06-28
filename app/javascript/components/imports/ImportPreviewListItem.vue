<template>
  <tr
    :class="`table-${importActionVariants[transaction.actionId]} side-strip side-strip-${importActionVariants[transaction.actionId]}`"
  >
    <td class="align-middle ps-3">
      <input
        :value="transaction.name"
        :disabled="!isEditable"
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
        :disabled="!isEditable"
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
        :disabled="!isEditable"
        required
        @change="handleCategoryChange(transaction.id, $event)"
      />
    </td>

    <td class="align-middle">
      <ImportActionsSelect
        :value="transaction.actionId"
        :allow-match="!!transaction.matches"
        required
        @change="handleActionChange(transaction.id, $event)"
      />
    </td>
  </tr>
</template>

<script>
import { computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useImportStore from '~/stores/ImportStore.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { VARIANTS_FOR_IMPORT_ACTIONS, IMPORT_ACTION_MATCH } from '~/utils/Constants.js';

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

    const isEditable = computed(() => props.transaction.actionId !== IMPORT_ACTION_MATCH);
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

      if (actionId === IMPORT_ACTION_MATCH) {
        handleMatchTransactionChange(transactionId, 0);
      }
    };

    const handleMatchTransactionChange = (importPreviewTransactionId, matchTransactionIndex) => {
      const matchTransaction = props.transaction.matches[matchTransactionIndex];
      importStore.updatePreviewData(importPreviewTransactionId, {
        name: matchTransaction.name,
        transactionDate: matchTransaction.transactionDate,
        categoryId: matchTransaction.categoryId,
      });
    };

    onMounted(() => {
      if (props.transaction.actionId === IMPORT_ACTION_MATCH) {
        handleMatchTransactionChange(props.transaction.id, 0);
      }
    });

    return {
      t,
      currencySymbol,
      isSpend,
      isIncome,
      isEditable,
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
