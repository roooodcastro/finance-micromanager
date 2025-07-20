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
      <div
        v-if="!isBlocked"
        class="d-flex"
      >
        <ImportActionsSelect
          v-model="transaction.action"
          data-transaction-input="action"
          :data-row="index"
          :allow-match="allowMatch"
          :name="`transactions[${transaction.id}][action]`"
          :disabled="isBlocked"
          :class="{ 'ImportActionsSelect__match-available': allowMatch }"
          required
          @change="handleActionChange(transaction.id, $event)"
        />

        <div
          v-if="transaction.action === IMPORT_ACTION_MATCH"
          class="btn btn-sm btn-outline-secondary d-flex align-items-center ms-2"
          @click="handleOpenMatchTransactionSelector(transaction.id)"
        >
          <FontAwesomeIcon
            icon="repeat"
            size="lg"
          />
        </div>
      </div>

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
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';
import { computed } from 'vue';

import { RulesProcessor } from '~/lib/transaction_predictions/RulesProcessor.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
import useImportStore from '~/stores/ImportStore.js';
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import {
  IMPORT_ACTION_BLOCK,
  IMPORT_ACTION_IMPORT,
  IMPORT_ACTION_MATCH,
  VARIANTS_FOR_IMPORT_ACTIONS,
} from '~/utils/Constants.js';
import { formatDate } from '~/utils/DateUtils.js';
import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import BlockedTransactionTooltip from '~/components/imports/BlockedTransactionTooltip.vue';
import ImportActionsSelect from '~/components/imports/ImportActionsSelect.vue';

export default {
  components: {
    BlockedTransactionTooltip,
    CategoriesSelect,
    FontAwesomeIcon,
    ImportActionsSelect,
  },

  props: {
    transactionId: {
      type: String,
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

    const transaction = computed(() => importTransactions.value.find(transaction => transaction.id === props.transactionId) ?? {});
    const isEditable = computed(() => transaction.value.action === IMPORT_ACTION_IMPORT);
    const isDateEditable = computed(() => transaction.value.action === IMPORT_ACTION_BLOCK);
    const isBlocked = computed(() => transaction.value.action === IMPORT_ACTION_BLOCK);
    const isMatch = computed(() => transaction.value.action === IMPORT_ACTION_MATCH);
    const allowMatch = computed(() => transaction.value.matches.length > 0);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);
    const isSpend = computed(() => transaction.value.amount < 0);
    const isIncome = computed(() => transaction.value.amount > 0);
    const categoryNameFor = categoryStore.categoryNameFor;

    const allowImportNameCreation = computed(() => {
      const importNameExists = importNames.value.some(importName => importName.importName === transaction.value.originalImportName);
      return !loadingImportNames.value && !importNameExists;
    });

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    const processTransactionPredictions = () => {
      if (transaction.value.action === IMPORT_ACTION_IMPORT) {
        const result = new RulesProcessor({...transaction}).processTransaction();
        if (!transaction.value.categoryId && !!result.categoryId) {
          importTransactionStore
            .update(transaction.value.id, { id: transaction.value.id, categoryId: result.categoryId });
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
      if (action === IMPORT_ACTION_MATCH) {
          handleOpenMatchTransactionSelector(transactionId);
      } else {
        importTransactionStore.update(transactionId, { id: transactionId, action, matchTransactionId: null }).then(() => {
          processTransactionPredictions();
        });
      }
    };

    const handleOpenMatchTransactionSelector = (transactionId) => {
      importTransactionStore.openMatchTransactionSelectorModal(transactionId);
    };

    const handleCreateImportName = () => {
      importNameStore.openFormModal(null, {
        importName: transaction.value.originalImportName,
        transactionName: transaction.value.name
      });
    };

    return {
      t,
      transaction,
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
      handleOpenMatchTransactionSelector,
      IMPORT_ACTION_MATCH,
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
