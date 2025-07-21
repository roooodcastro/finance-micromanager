<template>
  <LoadingOverlay
    :loading="loadingImportTransactions"
    :show-loading-message="!initialFetchDone"
  >
    <NoRecordsFound
      v-if="!importTransactions.length"
      class="m-3"
    />
    <table
      v-else
      class="table table-sm"
    >
      <thead>
        <tr>
          <th>{{ t('name_label') }}</th>
          <th class="text-end">
            {{ t('amount_label') }}
          </th>
          <th>{{ t('date_label') }}</th>
          <th>{{ t('category_label') }}</th>
          <th>{{ t('actions_label') }}</th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(transaction, index) in importTransactions"
          :key="transaction.id"
        >
          <ImportPreviewListItem
            :index="index"
            :transaction-id="transaction.id"
          />
        </template>
      </tbody>
    </table>
  </LoadingOverlay>
</template>

<script>
import { storeToRefs } from 'pinia';

import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import I18n from '~/utils/I18n.js';

import ImportPreviewListItem from '~/components/imports/ImportPreviewListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    LoadingOverlay,
    NoRecordsFound,
    ImportPreviewListItem,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.preview');

    const importTransactionStore = useImportTransactionStore();
    const { importTransactions, loading: loadingImportTransactions, initialFetchDone } = storeToRefs(importTransactionStore);

    return {
      t,
      importTransactions,
      loadingImportTransactions,
      initialFetchDone,
    };
  },
};
</script>
