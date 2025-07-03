<template>
  <tr
    :class="`table-${importActionVariants[transaction.action]} side-strip side-strip-${importActionVariants[transaction.action]}`"
  >
    <td class="align-middle ps-3">
      <template v-if="!isBlocked">
        <div class="d-flex align-items-center">
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
            data-transaction-input="name"
            :data-row="index"
            :name="`transactions[${transaction.id}][name]`"
            :value="transaction.name"
            class="form-control"
            required
            @change="handleNameChange(transaction.id, $event)"
          >
        </div>

        <div
          v-if="transaction.name !== transaction.originalImportName"
          class="d-flex gap-3 align-items-center px-3 pt-3"
        >
          {{ t('original_name_label') }} {{ `"${transaction.originalImportName}"` }}

          <a
            v-if="allowImportNameCreation"
            href="#"
            class="btn btn-sm btn-outline-primary py-0"
            @click="handleCreateImportName"
          >
            <FontAwesomeIcon :icon="['far', 'floppy-disk']" />
            {{ t('create_import_name_label') }}
          </a>
        </div>
      </template>
      <div
        v-else
        class="d-flex align-items-center"
      >
        <BlockedTransactionTooltip :message="t('import_block_reconciliation_reason')" />
        {{ transaction.name }}
      </div>
    </td>

    <td
      class="width-10rem text-end py-4"
      :class="{ 'text-debit': isSpend, 'text-credit': isIncome }"
    >
      {{ formatMoney(transaction.amount) }}
    </td>

    <td class="width-10rem py-4">
      {{ formatDate(transaction.transactionDate) }}
    </td>

    <td>
      <CategoriesSelect
        v-if="!isBlocked"
        data-transaction-input="category"
        :data-row="index"
        :value="[transaction.categoryId, transaction.subcategoryId].filter(x => x).join('|')"
        :placeholder="t('category_placeholder')"
        :name="`transactions[${transaction.id}][category_id]`"
        :disabled="!isEditable"
        required
        @change="handleCategoryChange(transaction.id, $event)"
      />
    </td>

    <td>
      <input
        type="hidden"
        :name="`transactions[${transaction.id}][match_transaction_id]`"
        :value="transaction.matchId"
      >
      <ImportActionsSelect
        v-if="!isBlocked"
        data-transaction-input="action"
        :data-row="index"
        :value="transaction.action"
        :allow-match="allowMatch"
        :name="`transactions[${transaction.id}][action]`"
        :disabled="isBlocked"
        :class="{ 'ImportActionsSelect__match-available': allowMatch }"
        required
        @change="handleActionChange(transaction.id, $event)"
      />
      <template v-else>
        <input
          type="hidden"
          :name="`transactions[${transaction.id}][action]`"
          :value="transaction.action"
        >
        {{ t('blocked_label') }}
      </template>
    </td>
  </tr>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useImportStore from '~/stores/ImportStore.js';
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
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
    index: {
      type: Number,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');

    const importStore = useImportStore();
    const importTransactionStore = useImportTransactionStore();
    const importNameStore = useImportNameStore();
    const profileStore = useProfileStore();
    const categoryStore = useCategoryStore();

    const { currentProfile } = storeToRefs(profileStore);
    const { categories } = storeToRefs(categoryStore);
    const { import: importObject } = storeToRefs(importStore);
    const { importTransactions } = storeToRefs(importTransactionStore);
    const { importNames, loading: loadingImportNames } = storeToRefs(importNameStore);

    const isEditable = computed(() => props.transaction.action === IMPORT_ACTION_IMPORT);
    const isDateEditable = computed(() => props.transaction.action === IMPORT_ACTION_BLOCK);
    const isBlocked = computed(() => props.transaction.action === IMPORT_ACTION_BLOCK);
    const isMatch = computed(() => props.transaction.action === IMPORT_ACTION_MATCH);
    const allowMatch = computed(() => props.transaction.matches.length > 0);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);
    const isSpend = computed(() => props.transaction.amount < 0);
    const isIncome = computed(() => props.transaction.amount > 0);
    const categoryNameFor = categoryStore.categoryNameFor;

    const allowImportNameCreation = computed(() => {
      const importNameExists = importNames.value.some(importName => importName.importName === props.transaction.originalImportName);
      return !loadingImportNames.value && !importNameExists;
    });

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    const processTransactionPredictions = () => {
      const transaction = importTransactions.value.find(importTransaction => importTransaction.id === props.transaction.id);
      if (transaction.action === IMPORT_ACTION_IMPORT) {
        const result = new RulesProcessor({...transaction}).processTransaction();
        if (!transaction.categoryId && !!result.categoryId) {
          importTransactionStore
            .update(props.transaction.id, { id: props.transaction.id, categoryId: result.categoryId });
        }
      }
    };

    const handleNameChange = (transactionId, event) => {
      const idParam = { importId: importObject.value.id, id: transactionId };

      importTransactionStore
        .update(idParam, { id: transactionId, name: event.target.value })
        .then(processTransactionPredictions);
    };

    const handleCategoryChange = (transactionId, categoryId) => {
      importTransactionStore
        .update(transactionId, { id: transactionId, categoryId })
        .then(processTransactionPredictions);
    };

    const handleActionChange = (transactionId, action) => {
      importTransactionStore.update(transactionId, { id: transactionId, action }).then(() => {
        processTransactionPredictions();

        if (action === IMPORT_ACTION_MATCH) {
          handleMatchTransactionChange(transactionId, 0);
        }
      });
    };

    const handleMatchTransactionChange = (importPreviewTransactionId, matchTransactionIndex) => {
      const matchTransaction = props.transaction.matches[matchTransactionIndex].transaction;
      importTransactionStore.update(importPreviewTransactionId, {
        id: importPreviewTransactionId,
        name: matchTransaction.name,
        transactionDate: matchTransaction.transactionDate,
        categoryId: [matchTransaction.categoryId, matchTransaction.subcategoryId].filter(x => x).join('|'),
        matchId: matchTransaction.id,
      });
    };

    const handleCreateImportName = () => {
      importNameStore.openFormModal(null, {
        importName: props.transaction.originalImportName,
        transactionName: props.transaction.name
      });
    };

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
      allowImportNameCreation,
      allowMatch,
      handleActionChange,
      handleCategoryChange,
      handleNameChange,
      handleCreateImportName,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ImportActionsSelect__match-available {
  outline: 0.25rem solid $secondary;
}
</style>
