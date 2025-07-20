<template>
  <GridTable
    :columns="transactionColumns"
    :rows="matches"
    :side-strip-color="sideStripColorFunction"
    always-mobile
    no-header
    :row-click-handler="handleMatchTransactionChange"
  >
    <template v-slot:default="{ row: match }">
      <MatchTransactionTableRow :match="match" />
    </template>
  </GridTable>
</template>

<script>
import I18n from '~/utils/I18n.js';
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import { IMPORT_ACTION_MATCH } from '~/utils/Constants.js';

import GridTable from '~/components/ui/GridTable.vue';
import MatchTransactionTableRow from '~/components/imports/MatchTransactionTableRow.vue';

export default {
  components: {
    GridTable,
    MatchTransactionTableRow,
  },

  props: {
    importTransactionId: {
      type: String,
      required: true,
    },

    matches: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.components.match_transaction_selector_modal');

    const importTransactionStore = useImportTransactionStore();

    const transactionColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('category_label'), side: 'left' },
      { label: t('amount_label'), side: 'right' },
      { label: t('transaction_date_label'), side: 'right' },
    ];

    const sideStripColorFunction = match => match.transaction.category.color;

    const handleMatchTransactionChange = (match) => {
      const matchTransaction = match.transaction;
      importTransactionStore.update(props.importTransactionId, {
        id: props.importTransactionId,
        name: matchTransaction.name,
        transactionDate: matchTransaction.transactionDate,
        categoryId: [matchTransaction.categoryId, matchTransaction.subcategoryId].filter(x => x).join('|'),
        matchTransactionId: matchTransaction.id,
        action: IMPORT_ACTION_MATCH,
      }, { waitForFetch: true }).then(() => {
        importTransactionStore.closeMatchTransactionSelectorModal();
      });
    };

    return {
      transactionColumns,
      sideStripColorFunction,
      handleMatchTransactionChange,
    };
  },
};
</script>
