import { importsImportTransactions as importTransactionsApi } from '~/api/all.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('importTransaction', {
  resourceName: 'importTransaction',
  resourcesName: 'importTransactions',
  formId: null,
  api: importTransactionsApi,

  state: {
    importTransactions: [],
    importTransaction: null,
    fetchParams: {},
    urlParams: {},
  },
});
