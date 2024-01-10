import { transactionAutomations as transactionAutomationsApi } from '~/api/all.js';
import { TRANSACTION_AUTOMATION_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('transactionAutomation', {
  resourceName: 'transactionAutomation',
  resourcesName: 'transactionAutomations',
  formId: TRANSACTION_AUTOMATION_FORM_ID,
  api: transactionAutomationsApi,

  state: {
    transactionAutomations: [],
    fetchParams: {},
  },

  actions: {},
});
