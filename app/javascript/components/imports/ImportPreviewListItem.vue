<template>
  <tr
    :class="`table-${importActionVariants[transaction.actionId]} side-strip side-strip-${importActionVariants[transaction.actionId]}`"
  >
    <td class="align-middle ps-3">
      <div
        v-if="!isBlocked"
        class="d-flex align-items-center"
      >
        <a
          v-if="isMatch && transaction.matches.length > 1"
          href="#"
          class="btn btn-context-action rounded-circle me-2"
        >
          <FontAwesomeIcon
            icon="list-ol"
            size="lg"
          />
        </a>

        <input
          v-if="!isBlocked"
          :name="`transactions[${transaction.id}][name]`"
          :value="transaction.name"
          class="form-control"
          required
          @input="handleNameChange(transaction.id, $event)"
        >
      </div>
      <div
        v-else
        class="d-flex align-items-center"
      >
        <BlockedTransactionTooltip :message="t('import_block_reconciliation_reason')" />
        {{ transaction.name }}
      </div>
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
        :disabled="!isEditable && !isDateEditable"
        :name="`transactions[${transaction.id}][transaction_date]`"
        class="form-control px-3"
        type="date"
        required
        @change="handleDateChange(transaction.id, $event)"
      >
    </td>

    <td class="align-middle">
      <CategoriesSelect
        v-if="!isBlocked"
        :value="transaction.categoryId"
        :placeholder="t('category_placeholder')"
        :name="`transactions[${transaction.id}][category_id]`"
        :disabled="!isEditable"
        required
        @change="handleCategoryChange(transaction.id, $event)"
      />
    </td>

    <td class="align-middle">
      <input
        type="hidden"
        :name="`transactions[${transaction.id}][match_transaction_id]`"
        :value="transaction.matchId"
      >
      <ImportActionsSelect
        v-if="!isBlocked"
        :value="transaction.actionId"
        :allow-match="!!transaction.matches.length"
        :name="`transactions[${transaction.id}][action_id]`"
        :disabled="isBlocked"
        required
        @change="handleActionChange(transaction.id, $event)"
      />
      <template v-else>
        <input
          type="hidden"
          :name="`transactions[${transaction.id}][action_id]`"
          :value="transaction.actionId"
        >
        {{ t('blocked_label') }}
      </template>
    </td>
  </tr>
</template>

<script>
import { computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useImportStore from '~/stores/ImportStore.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import { RulesProcessor } from '~/lib/transaction_predictions/RulesProcessor.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import {
  VARIANTS_FOR_IMPORT_ACTIONS,
  IMPORT_ACTION_IMPORT,
  IMPORT_ACTION_BLOCK,
  IMPORT_ACTION_MATCH
} from '~/utils/Constants.js';

import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import ImportActionsSelect from '~/components/imports/ImportActionsSelect.vue';
import BlockedTransactionTooltip from '~/components/imports/BlockedTransactionTooltip.vue';

export default {
  components: {
    BlockedTransactionTooltip,
    CategoriesSelect,
    FontAwesomeIcon,
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
    const transactionPredictionStore = useTransactionPredictionStore();


    const { currentProfile } = storeToRefs(profileStore);
    const { categories } = storeToRefs(categoryStore);
    const { transactionPredictions } = storeToRefs(transactionPredictionStore);

    const isEditable = computed(() => props.transaction.actionId === IMPORT_ACTION_IMPORT);
    const isDateEditable = computed(() => props.transaction.actionId === IMPORT_ACTION_BLOCK);
    const isBlocked = computed(() => props.transaction.actionId === IMPORT_ACTION_BLOCK);
    const isMatch = computed(() => props.transaction.actionId === IMPORT_ACTION_MATCH);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);
    const isSpend = computed(() => props.transaction.amount < 0);
    const isIncome = computed(() => props.transaction.amount > 0);
    const categoryNameFor = categoryStore.categoryNameFor;

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    const processTransactionPredictions = () => {
      const transaction = {...importStore.getPreviewData(props.transaction.id)};
      if (transaction.actionId === IMPORT_ACTION_IMPORT) {
        const result = new RulesProcessor(transaction).processTransaction();
        importStore.updatePreviewData(props.transaction.id, { transactionDate: result.transactionDate, categoryId: result.categoryId });
      }
    };

    const handleNameChange = (transactionId, event) => {
      importStore.updatePreviewData(transactionId, { name: event.target.value });
      processTransactionPredictions();
    };

    const handleDateChange = (transactionId, event) => {
      importStore.updatePreviewData(transactionId, { transactionDate: event.target.value });
      processTransactionPredictions();
    };

    const handleCategoryChange = (transactionId, categoryId) => {
      importStore.updatePreviewData(transactionId, { categoryId });
      processTransactionPredictions();
    };

    const handleActionChange = (transactionId, actionId) => {
      importStore.updatePreviewData(transactionId, { actionId });

      if (actionId === IMPORT_ACTION_MATCH) {
        handleMatchTransactionChange(transactionId, 0);
      }
    };

    const handleMatchTransactionChange = (importPreviewTransactionId, matchTransactionIndex) => {
      const matchTransaction = props.transaction.matches[matchTransactionIndex].transaction;
      importStore.updatePreviewData(importPreviewTransactionId, {
        name: matchTransaction.name,
        transactionDate: matchTransaction.transactionDate,
        categoryId: matchTransaction.categoryId,
        matchId: matchTransaction.id,
      });
    };

    onMounted(() => {
      if (props.transaction.actionId === IMPORT_ACTION_MATCH) {
        handleMatchTransactionChange(props.transaction.id, 0);
      }

      if (!transactionPredictions.value.length) {
        transactionPredictionStore.fetchCollection();
      }
    });

    return {
      t,
      currencySymbol,
      isSpend,
      isIncome,
      isEditable,
      isDateEditable,
      isBlocked,
      isMatch,
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
